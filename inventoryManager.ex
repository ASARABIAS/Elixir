defmodule InventoryManager do

  # Definimos la lista producto y carrito de compra
  defstruct products: [],  shopping_cart: []

  # Funcion para agregar producto
  def add_product(inventory, name, price, stock) do

    products = inventory.products
    id = length(products) + 1
    product = %{id: id, name: name, price: price, stock: stock}
    %InventoryManager{products: products ++ [product]}

  end

  # Funcion para listar los productos
  def list_products(inventory) do

    Enum.each(inventory.products, fn product ->
      IO.puts("#{product.id} - #{product.name} $#{product.price} # #{product.stock}")
    end)

  end

   # Funcion para aumentar el stock
  def increase_stock(inventory, id, quantity) do

    updated_products = Enum.map(inventory.products, fn product ->
      if product.id == id do
        Map.put(product, :stock, product.stock + quantity)
      else
        product
      end
    end)

    %InventoryManager{products: updated_products}

  end

  # Funcion agregar producto al carrito
  def sell_product(inventory, id, quantity) do

    {updated_products, updated_cart} =
      Enum.reduce(inventory.products, {[], inventory.shopping_cart}, fn product, {acc_products, acc_cart} ->
        if product.id == id do
          if product.stock >= quantity do
            updated_product = Map.put(product, :stock, product.stock - quantity)
            updated_cart = [{id, quantity} | acc_cart]
            {[updated_product | acc_products], updated_cart}
          else
            IO.puts("No puedes agregar la cantidad: #{quantity} al carrito porque solo tienes en el stock: #{product.stock}")
            {[product | acc_products], acc_cart}
          end
        else
          {[product | acc_products], acc_cart}
        end
      end)

      IO.inspect(updated_cart)

    %InventoryManager{products: updated_products, shopping_cart: updated_cart}

  end

  # Funcion para ver carrito
  def view_cart(inventory) do
    Enum.each(inventory.shopping_cart, fn shopping_cart ->
      product = Enum.find(inventory.products, fn product ->
        product.id == elem(shopping_cart, 0)
      end)
      total_value = product.price*elem(shopping_cart, 1)
      total_value = :io_lib.format("~.2f", [total_value])
      |> List.to_string()
      IO.puts("#{elem(shopping_cart, 0)} - #{product.name} cantidad: ##{elem(shopping_cart, 1)}, Total: $#{total_value}")
    end)
  end

  # Funcion para cobrar carrito
  def checkout(inventory) do
    view_cart(inventory)

    sum_total_value = Enum.reduce(inventory.shopping_cart, 0, fn shopping_cart, acc ->
      product = Enum.find(inventory.products, fn product ->
        product.id == elem(shopping_cart, 0)
      end)
      total_value = product.price * elem(shopping_cart, 1)
      acc + total_value
    end)

    sum_total_value = :io_lib.format("~.2f", [sum_total_value])
      |> List.to_string()

    IO.puts("Total a pagar: $#{sum_total_value}")

    %InventoryManager{shopping_cart: []}
  end


  # Main funcion para correr el proyecto
  def run do

    inventory_manager = %InventoryManager{}
    loop(inventory_manager)

  end

  # Funcion privada para el bucle principal.
  defp loop(inventory_manager) do
    IO.puts("""
    \n
    ------------------------------------
    \n
    Gestor de Inventario
    1. Agregar producto
    2. Listar producto
    3. Aumentar stock
    4. Vender producto
    5. Ver carrito
    6. Realizar Checkout
    7. Salir
    """)

    IO.write("Seleccione una opción: ")
    option = String.trim(IO.gets(""))
    option = String.to_integer(option)

    IO.puts("""
    \n
    ------------------------------------
    """)

    if option == 1 do
      IO.write("Ingrese la nombre del producto: ")
      name = String.trim(IO.gets(""))
      IO.write("Ingrese el precio del producto: ")
      price = String.trim(IO.gets(""))
      {price, _} = Float.parse(price)
      IO.write("Ingrese el stock del producto: ")
      stock = String.trim(IO.gets(""))
      stock = String.to_integer(stock)
      inventory_manager =  add_product(inventory_manager, name, price, stock)
      loop(inventory_manager)
    else
      if option == 2 do
        list_products(inventory_manager)
        loop(inventory_manager)
      else
        if option == 3 do
          IO.write("Ingrese el ID del producto: ")
          id = String.trim(IO.gets(""))
          id = String.to_integer(id)
          IO.write("Ingrese la cantidad a aumentar el stock del producto: ")
          quantity = String.trim(IO.gets(""))
          quantity = String.to_integer(quantity)
          inventory_manager = increase_stock(inventory_manager, id, quantity)
          loop(inventory_manager)
        else
          if option == 4 do
            IO.write("Ingrese el ID del producto para agregar al carrito: ")
            id = String.trim(IO.gets(""))
            id = String.to_integer(id)
            IO.write("Ingrese la cantidad del producto vendido: ")
            quantity = String.trim(IO.gets(""))
            quantity = String.to_integer(quantity)
            inventory_manager = sell_product(inventory_manager, id, quantity)
            loop(inventory_manager)
          else
            if option == 5 do
              view_cart(inventory_manager)
              loop(inventory_manager)
            else
              if option == 6 do
                inventory_manager = checkout(inventory_manager)
                loop(inventory_manager)
              else
                if option == 7 do
                  IO.puts("¡Adiós!")
                else
                  IO.puts("Opción no válida.")
                  loop(inventory_manager)
                end
              end
            end
          end
        end
      end
    end
  end


end

# Execute the task manager
InventoryManager.run()
