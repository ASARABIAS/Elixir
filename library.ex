defmodule Library do
  @moduledoc """
  A module for managing a library system with books and users.
  """

  defmodule Book do
    @moduledoc """
    A struct representing a book in the library.
    """
    defstruct title: "", author: "", isbn: "", available: true
  end

  defmodule User do
    @moduledoc """
    A struct representing a user of the library.
    """
    defstruct name: "", id: "", borrowed_books: []
  end

  @doc """
  Adds a book to the library.

  ## Parameters
  - library: The current list of books in the library.
  - book: The book struct to add.

  ## Examples

      iex> library = []
      iex> book = %Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890"}
      iex> Library.add_book(library, book)
      [%Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890", available: true}]
  """
  def add_book(library, %Book{} = book) do
    library ++ [book]
  end

  @doc """
  Adds a user to the library system.

  ## Parameters
  - users: The current list of users.
  - user: The user struct to add.

  ## Examples

      iex> users = []
      iex> user = %Library.User{name: "Alice", id: "1"}
      iex> Library.add_user(users, user)
      [%Library.User{name: "Alice", id: "1", borrowed_books: []}]
  """
  def add_user(users, %User{} = user) do
    users ++ [user]
  end

  @doc """
  Allows a user to borrow a book from the library.

  ## Parameters
  - library: The current list of books in the library.
  - users: The current list of users.
  - user_id: The ID of the user borrowing the book.
  - isbn: The ISBN of the book to borrow.

  ## Examples

      iex> library = [%Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890", available: true}]
      iex> users = [%Library.User{name: "Alice", id: "1", borrowed_books: []}]
      iex> Library.borrow_book(library, users, "1", "1234567890")
      {:ok, [%Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890", available: false}], [%Library.User{name: "Alice", id: "1", borrowed_books: [%Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890", available: false}]}]}
  """
  def borrow_book(library, users, user_id, isbn) do
    user = Enum.find(users, &(&1.id == user_id))
    book = Enum.find(library, &(&1.isbn == isbn && &1.available))

    cond do
      user == nil -> {:error, "Usuario no encontrado"}
      book == nil -> {:error, "Libro no disponible"}
      true ->
        updated_book = %{book | available: false}
        updated_user = %{user | borrowed_books: user.borrowed_books ++ [updated_book]}

        updated_library = Enum.map(library, fn
          b when b.isbn == isbn -> updated_book
          b -> b
        end)

        updated_users = Enum.map(users, fn
          u when u.id == user_id -> updated_user
          u -> u
        end)
        #IO.inspect( {:ok, updated_library, updated_users})

        {:ok, updated_library, updated_users}

    end
  end

  @doc """
  Allows a user to return a borrowed book to the library.

  ## Parameters
  - library: The current list of books in the library.
  - users: The current list of users.
  - user_id: The ID of the user returning the book.
  - isbn: The ISBN of the book to return.

  ## Examples

      iex> library = [%Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890", available: false}]
      iex> users = [%Library.User{name: "Alice", id: "1", borrowed_books: [%Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890", available: false}]}]
      iex> Library.return_book(library, users, "1", "1234567890")
      {:ok, [%Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890", available: true}], [%Library.User{name: "Alice", id: "1", borrowed_books: []}]}
  """
  def return_book(library, users, user_id, isbn) do
    user = Enum.find(users, &(&1.id == user_id))
    book = Enum.find(user.borrowed_books, &(&1.isbn == isbn))

    cond do
      user == nil -> {:error, "Usuario no encontrado"}
      book == nil -> {:error, "Libro no encontrado en los libros prestados del usuario"}
      true ->
        updated_book = %{book | available: true}
        updated_user = %{user | borrowed_books: Enum.filter(user.borrowed_books, &(&1.isbn != isbn))}

        updated_library = Enum.map(library, fn
          b when b.isbn == isbn -> updated_book
          b -> b
        end)

        updated_users = Enum.map(users, fn
          u when u.id == user_id -> updated_user
          u -> u
        end)
        #IO.inspect( {:ok, updated_library, updated_users})

        {:ok, updated_library, updated_users}
    end
  end

  def return_book_all(library, users, user_id) do
    user = Enum.find(users, &(&1.id == user_id))

    cond do
      user == nil -> {:error, "Usuario no encontrado"}
      user.borrowed_books == [] -> {:error, "Libro no encontrado en los libros prestados del usuario"}
      true ->
        update_books = user.borrowed_books
        updated_user = %{user | borrowed_books: []}

        updated_library = Enum.map(library, fn b ->
          if Library.book_in_update_books?(b, update_books) do
            %{b | available: true}
          else
            b
          end
        end)

        updated_users = Enum.map(users, fn
          u when u.id == user_id -> updated_user
          u -> u
        end)
        IO.inspect( {:ok, updated_library, updated_users})

        {:ok, updated_library, updated_users}
    end
  end

  def book_in_update_books?(book, update_books) do
    Enum.any?(update_books, &(&1.isbn == book.isbn))
  end

  @doc """
  Lists all books in the library.

  ## Parameters
  - library: The current list of books in the library.

  ## Examples

      iex> library = [%Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890"}]
      iex> Library.list_books(library)
      [%Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890"}]
  """
  def list_books(library) do
    Enum.each(library, &(IO.puts("#{&1.isbn} - #{&1.title} - #{&1.author} - #{&1.available}")))
  end

  def list_available_books(library) do

    available_books = Enum.filter(library, &(&1.available))
    list_books(available_books)

  end

  def list_loans_books(library) do

    loans_books = Enum.filter(library,&(&1.available == false))
    list_books(loans_books)

  end

  @doc """
  Lists all users in the library system.

  ## Parameters
  - users: The current list of users.

  ## Examples

      iex> users = [%Library.User{name: "Alice", id: "1"}]
      iex> Library.list_users(users)
      [%Library.User{name: "Alice", id: "1"}]
  """
  def list_users(users) do

    Enum.each(users, &(IO.puts("#{&1.id} - #{&1.name} ")))

  end

  @doc """
  Lists all books borrowed by a specific user.

  ## Parameters
  - users: The current list of users.
  - user_id: The ID of the user whose borrowed books are to be listed.

  ## Examples

      iex> users = [%Library.User{name: "Alice", id: "1", borrowed_books: [%Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890"}]}]
      iex> Library.books_borrowed_by_user(users, "1")
      [%Library.Book{title: "Elixir in Action", author: "Saša Jurić", isbn: "1234567890"}]
  """
  def books_borrowed_by_user(users, user_id) do
    user = Enum.find(users, &(&1.id == user_id))
    # if user, do: user.borrowed_books, else: []

    if user do
      #IO.inspect( user)
      list_books(user.borrowed_books)
    else
      IO.puts("No tienes libros en su poder")
    end

  end


  # Main funcion para correr el proyecto
  def run do
    books = []
    users = []

    loop(books, users)
  end

  # Funcion privada para el bucle principal.
  defp loop(books, users) do
    IO.puts("""
    \n
    ------------------------------------
    \n
    Gestión de Biblioteca
    1. Gestión de Libros
    2. Gestión de Usuarios
    3. Préstamo de Libros
    4. Salir
    """)

    IO.write("Seleccione una opción: ")
    option = String.trim(IO.gets(""))
    option = String.to_integer(option)

    IO.puts("""
    \n
    ------------------------------------
    """)

    case option do
      1 ->
        books = book_management(books)
        loop(books, users)
      2 ->
        users = user_management(users)
        loop(books, users)
      3 ->
        {:ok, books, users} = loan_management(books, users)
        loop(books, users)
      4 ->
        IO.puts("¡Adiós!")
      _ ->
        IO.puts("Opción no válida.")
        loop(books, users)
    end
  end

  defp book_management(books) do
    IO.puts("""
    \n
    ------------------------------------
    \n
    Gestión de Biblioteca - Gestión de Libros
    1. Agregar libro
    2. Listar libros
    3. Listar libros disponibles
    4. Listar libros prestados
    5. Salir
    """)

    IO.write("Seleccione una opción: ")
    option = String.trim(IO.gets(""))
    option = String.to_integer(option)

    IO.puts("""
    \n
    ------------------------------------
    """)

    case option do
      1 ->
        IO.write("Ingrese el titulo del libro: ")
        title = String.trim(IO.gets(""))
        IO.write("Ingrese el autor del libro: ")
        author = String.trim(IO.gets(""))
        IO.write("Ingrese el ISBN del libro: ")
        isbn = String.trim(IO.gets(""))

        book = %Library.Book{title: title, author: author, isbn: isbn}
        books = Library.add_book(books, book)
        book_management(books)
      2 ->
        Library.list_books(books)
        book_management(books)
      3 ->
        Library.list_available_books(books)
        book_management(books)
      4 ->
        Library.list_loans_books(books)
        book_management(books)
      5 ->
        IO.puts("¡Regresando...!")
        books
      _ ->
        IO.puts("Opción no válida.")
        book_management(books)
    end
  end

  defp user_management(users) do
    IO.puts("""
    \n
    ------------------------------------
    \n
    Gestión de Biblioteca - Gestión de Usuarios
    1. Agregar Usuario
    2. Listar Usuario
    3. Salir
    """)

    IO.write("Seleccione una opción: ")
    option = String.trim(IO.gets(""))
    option = String.to_integer(option)

    IO.puts("""
    \n
    ------------------------------------
    """)

    case option do
      1 ->
        IO.write("Ingrese el name del usuario: ")
        name = String.trim(IO.gets(""))

        id = Integer.to_string(length(users) +1)
        user =  %Library.User{name: name, id: id}
        users = Library.add_user(users, user)
        user_management(users)
      2 ->
        Library.list_users(users)
        user_management(users)
      3 ->
        IO.puts("¡Regresando...!")
        users
      _ ->
        IO.puts("Opción no válida.")
        user_management(users)
    end
  end

  defp loan_management(books, users) do

    IO.puts("""
    \n
    ------------------------------------
    \n
    Gestión de Biblioteca - Gestión de Prestamos
    1. Pedir prestado un libro disponible
    2. Devolver libro
    3. Listar libros prestados para el usuario
    4. Devolver todos los libros para el usuario
    5. Salir
    """)

    IO.write("Seleccione una opción: ")
    option = String.trim(IO.gets(""))
    option = String.to_integer(option)

    IO.puts("""
    \n
    ------------------------------------
    """)

    case option do
      1 ->
        IO.write("Ingrese el id del usuario: ")
        user_id = String.trim(IO.gets(""))
        IO.write("Ingrese el ISBN del libro: ")
        isbn = String.trim(IO.gets(""))

        {books, users}  = case Library.borrow_book(books, users, user_id, isbn) do
          {:ok, updated_books, updated_users} ->
            IO.puts("Préstamo exitoso")
            {updated_books, updated_users}
          {:error, reason} ->
            IO.puts("Error: #{reason}")
            {books, users}
        end

        loan_management(books, users)
      2 ->
        IO.write("Ingrese el id del usuario que va a devolver el libro: ")
        user_id = String.trim(IO.gets(""))
        IO.write("Ingrese el ISBN del libro que van a devolver: ")
        isbn = String.trim(IO.gets(""))

        {books, users}  = case Library.return_book(books, users, user_id, isbn) do
          {:ok, updated_books, updated_users} ->
            IO.puts("Libro devuelto exitosamente")
            {updated_books, updated_users}
          {:error, reason} ->
            IO.puts("Error: #{reason}")
            {books, users}
        end

        loan_management(books, users)
      3 ->
        IO.write("Ingrese el id del usuario: ")
        user_id = String.trim(IO.gets(""))

        Library.books_borrowed_by_user(users, user_id)
        loan_management(books, users)
      4 ->
        IO.write("Ingrese el id del usuario: ")
        user_id = String.trim(IO.gets(""))

        {books, users}  = case Library.return_book_all(books, users, user_id) do
          {:ok, updated_books, updated_users} ->
            IO.puts("Libros devuelto exitosamente")
            {updated_books, updated_users}
          {:error, reason} ->
            IO.puts("Error: #{reason}")
            {books, users}
        end
        loan_management(books, users)
      5 ->
        IO.puts("¡Regresando...!")
        {:ok, books, users}
      _ ->
        IO.puts("Opción no válida.")
        loan_management(books, users)
    end
  end

end


# Execute the Library manager
Library.run()
