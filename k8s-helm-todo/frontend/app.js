document.addEventListener('DOMContentLoaded', () => {
    // API base URL (use relative URL for the API)
    const apiBaseUrl = '/api/todos';

    // DOM elements
    const todoList = document.getElementById('todoList');
    const todoTitle = document.getElementById('todoTitle');
    const todoDescription = document.getElementById('todoDescription');
    const addTodoBtn = document.getElementById('addTodoBtn');

    // Fetch all todos
    const fetchTodos = async () => {
        try {
            const response = await fetch(apiBaseUrl);
            if (!response.ok) {
                throw new Error('Failed to fetch todos');
            }
            const todos = await response.json();
            renderTodos(todos);
        } catch (error) {
            console.error('Error fetching todos:', error);
        }
    };

    // Render todos in the list
    const renderTodos = (todos) => {
        todoList.innerHTML = '';

        if (todos.length === 0) {
            todoList.innerHTML = '<li class="todo-item">No todos yet. Add one above!</li>';
            return;
        }

        todos.forEach(todo => {
            const li = document.createElement('li');
            li.className = `todo-item ${todo.completed ? 'completed' : ''}`;
            li.innerHTML = `
                <div class="todo-content">
                    <h3>${todo.title}</h3>
                    ${todo.description ? `<p>${todo.description}</p>` : ''}
                </div>
                <div class="todo-actions">
                    <button class="complete-btn" data-id="${todo.id}">${todo.completed ? 'Uncomplete' : 'Complete'}</button>
                    <button class="delete-btn" data-id="${todo.id}">Delete</button>
                </div>
            `;
            todoList.appendChild(li);
        });

        // Add event listeners to the newly created buttons
        document.querySelectorAll('.complete-btn').forEach(btn => {
            btn.addEventListener('click', toggleTodoComplete);
        });

        document.querySelectorAll('.delete-btn').forEach(btn => {
            btn.addEventListener('click', deleteTodo);
        });
    };

    // Add a new todo
    const addTodo = async () => {
        const title = todoTitle.value.trim();
        const description = todoDescription.value.trim();

        if (!title) {
            alert('Please enter a title');
            return;
        }

        try {
            const response = await fetch(apiBaseUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ title, description })
            });

            if (!response.ok) {
                throw new Error('Failed to add todo');
            }

            // Clear inputs
            todoTitle.value = '';
            todoDescription.value = '';

            // Refresh the todo list
            fetchTodos();
        } catch (error) {
            console.error('Error adding todo:', error);
        }
    };

    // Toggle todo complete status
    const toggleTodoComplete = async (event) => {
        const todoId = event.target.dataset.id;
        const isCompleted = event.target.textContent === 'Uncomplete';

        try {
            const response = await fetch(`${apiBaseUrl}/${todoId}`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ completed: !isCompleted })
            });

            if (!response.ok) {
                throw new Error('Failed to update todo');
            }

            // Refresh the todo list
            fetchTodos();
        } catch (error) {
            console.error('Error toggling todo complete status:', error);
        }
    };

    // Delete a todo
    const deleteTodo = async (event) => {
        const todoId = event.target.dataset.id;

        try {
            const response = await fetch(`${apiBaseUrl}/${todoId}`, {
                method: 'DELETE'
            });

            if (!response.ok) {
                throw new Error('Failed to delete todo');
            }

            // Refresh the todo list
            fetchTodos();
        } catch (error) {
            console.error('Error deleting todo:', error);
        }
    };

    // Add event listener to the add button
    addTodoBtn.addEventListener('click', addTodo);

    // Load todos when the page loads
    fetchTodos();
});
