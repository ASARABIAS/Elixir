# Define the TaskManager module
defmodule TaskManager do
  # Define the struct for TaskManager with a single field 'tasks'
  defstruct tasks: []

  # Function to add a new task
  # Parameters:
  #   task_manager: The current TaskManager struct
  #   description: The description of the new task
  # Returns: Updated TaskManager struct
  def add_task(task_manager, description) do
    # Get the current tasks
    #%{tasks: []}
    tasks = task_manager.tasks
    # Generate a new ID
    id = length(tasks) + 1
    # Create a new task map
    task = %{id: id, description: description, completed: false}
    # Update the TaskManager struct with the new task
    %TaskManager{tasks: tasks ++ [task]}
  end

  # Function to list all tasks
  # Parameters:
  #   task_manager: The current TaskManager struct
  def list_tasks(task_manager) do
    # Iterate through each task and print its details
    Enum.each(task_manager.tasks, fn task ->
      status = if task.completed, do: "Completada", else: "Pendiente"
      IO.puts("#{task.id}. #{task.description} [#{status}]")
    end)
  end


  # Function to mark a task as completed
  # Parameters:
  #   task_manager: The current TaskManager struct
  #   id: The ID of the task to be completed
  # Returns: Updated TaskManager struct
  def complete_task(task_manager, id) do
    # Update the tasks, marking the specified task as completed
    updated_tasks = Enum.map(task_manager.tasks, fn task ->
      if task.id == id do
        Map.put(task, :completed, true)
      else
        task
      end
    end)
    # Return the updated TaskManager struct
    %TaskManager{tasks: updated_tasks}
  end

  # Main function to run the task manager
  def run do
    # Initialize an empty TaskManager
    task_manager = %TaskManager{}
    # Start the main loop
    loop(task_manager)
  end

  # Private function for the main loop
  # Parameters:
  #   task_manager: The current TaskManager struct
  defp loop(task_manager) do
    # Display the menu
    IO.puts("""
    Gestor de Tareas
    1. Agregar Tarea
    2. Listar Tareas
    3. Completar Tarea
    4. Salir
    """)

    # Get user input
    IO.write("Seleccione una opción: ")
    option = String.trim(IO.gets(""))
    option = String.to_integer(option)

    # Process the user's choice
    if option == 1 do
      IO.write("Ingrese la descripción de la tarea: ")
      description = String.trim(IO.gets(""))
      task_manager = add_task(task_manager, description)
      loop(task_manager)
    else
      if option == 2 do
        list_tasks(task_manager)
        loop(task_manager)
      else
        if option == 3 do
          IO.write("Ingrese el ID de la tarea a completar: ")
          id = String.trim(IO.gets(""))
          id = String.to_integer(id)
          task_manager = complete_task(task_manager, id)
          loop(task_manager)
        else
          if option == 4 do
            IO.puts("¡Adiós!")
          else
            IO.puts("Opción no válida.")
            loop(task_manager)
          end
        end
      end
    end
  end
end

# Execute the task manager
TaskManager.run()
