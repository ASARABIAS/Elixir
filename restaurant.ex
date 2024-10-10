defmodule Restaurant do
  @moduledoc """
  Módulo que representa un restaurante que permite adminsitrar el menu y publicarlo
  """

  @doc """
  Inicia el proceso del restaurante.
  """
  def start do
    spawn(fn -> loop([]) end)
  end

  @doc """
  Crea una nueva orden

  ## Parámetros
  - `restaurant_pid`: PID del proceso del resurante.
  - `dishe_pid`: PID del proceso del plato.
  """
  def new_dishe(restaurant_pid, dishe_pid) do
    send(restaurant_pid, {:new_dishe, dishe_pid})
  end

  @doc """
  Liberada la orden a los clientes.

  ## Parámetros
  - `restaurant_pid`: PID del proceso del resurante.
  - `dishe_pid`: PID del proceso del plato.
  """
  def release_dishe(restaurant_pid, dishe_pid) do
    send(restaurant_pid, {:release_dishe, dishe_pid})
  end

  @doc """
  Eliminar menu

  ## Parámetros
  - `restaurant_pid`: PID del proceso del restaurante.
  """
  def menu(restaurant_pid ) do
    send(restaurant_pid, {:publish })
  end

  @doc false
  defp loop(menu) do
    receive do
      {:new_dishe, dishe_pid} ->
        IO.puts("Nuevo plato")
        loop([dishe_pid | menu])

      {:release_dishe, dishe_pid} ->
        IO.puts("Eliminando plato del menu")
        loop(List.delete(menu, dishe_pid))

      {:publish } ->
        IO.puts("publicar menu:")
        Enum.each(menu, fn dishe ->
          send(dishe, {:dishe})
        end)
        loop(menu)

      _ ->
        IO.puts("Invalid Message")
        loop(menu)
    end
  end
end

defmodule Dishe do
  @moduledoc """
  Módulo que representa el plato.
  """

  @doc """
  Inicia un proceso de plato.

  ## Parámetros
  - `name`: Nombre del plato.
  """
  def name(name) do
    spawn(fn -> loop(name) end)
  end

  @doc false
  def loop(name) do
    receive do
      {:dishe} ->
        IO.puts("Plato: #{name}")
        loop(name)

      _ ->
        IO.puts("Invalid Message")
        loop(name)
    end
  end
end

# Ejemplo de uso
# c("restaurant.ex")
# restaurant_pid = Restaurant.start()

# plato1 = Dishe.name("Plato #1 {ingredientes}")
# plato2 = Dishe.name("Plato #2 {ingredientes}")

# Restaurant.new_dishe(restaurant_pid, plato1)
# Restaurant.new_dishe(restaurant_pid, plato2)

# Restaurant.menu(restaurant_pid)

# Restaurant.release_dishe(restaurant_pid, plato1)

# Restaurant.menu(restaurant_pid)
