import { defineStore } from 'pinia';
import TodoGroupAPI from '@/apis/todo_app/todo_group.api';
import TodoAPI from '@/apis/todo_app/todo.api';

interface Todo {
  id: number;
  title: string;
  notes: string | null;
  completed: boolean;
  position: number;
  todo_group_id: number;
  created_at: string;
  updated_at: string;
}

interface TodoGroup {
  id: number;
  name: string;
  position: number;
  todos_count: number;
  completed_count: number;
  pending_count: number;
  todos: Todo[];
  preview_todos?: Todo[];
  created_at: string;
  updated_at: string;
}

export const useTodoStore = defineStore({
  id: 'todo-store',
  state: () => ({
    todoGroups: [] as TodoGroup[],
    selectedGroup: null as TodoGroup | null,
    loading: false,
    searching: false,
    search: '',
    groupsPagination: {} as { current_page?: number; total_pages?: number; total_items?: number },
    groupsPage: 1,
    loadingMoreGroups: false,
  }),
  getters: {
    selectedGroupTodos(): Todo[] {
      return this.selectedGroup?.todos || [];
    },
    pendingTodos(): Todo[] {
      return this.selectedGroupTodos.filter((t) => !t.completed);
    },
    completedTodos(): Todo[] {
      return this.selectedGroupTodos.filter((t) => t.completed);
    },
  },
  actions: {
    async fetchTodoGroups(page = 1, append = false) {
      if (page === 1) {
        this.loading = true;
      } else {
        this.loadingMoreGroups = true;
      }
      try {
        const res = await TodoGroupAPI.fetchTodoGroups(page, this.search);
        const groups = res?.todo_groups || [];

        this.todoGroups = append ? this.todoGroups.concat(groups) : groups;
        this.groupsPagination = {
          current_page: res?.meta?.pagy?.page,
          total_pages: res?.meta?.pagy?.pages,
          total_items: res?.meta?.total_count,
        };
        this.groupsPage = this.groupsPagination.current_page || page;

        // Keep selected group in sync if it exists
        if (this.selectedGroup) {
          const existingGroup = this.todoGroups.find((g) => g.id === this.selectedGroup?.id);
          if (existingGroup) {
            this.selectedGroup = existingGroup;
          }
        }
      } finally {
        this.loading = false;
        this.loadingMoreGroups = false;
      }
    },

    async fetchMoreTodoGroups() {
      if (this.loading || this.loadingMoreGroups) return;
      const current = this.groupsPagination?.current_page || 1;
      const total = this.groupsPagination?.total_pages || 1;
      if (current >= total) return;
      await this.fetchTodoGroups(current + 1, true);
    },

    async fetchTodoGroup(id: number) {
      const res = await TodoGroupAPI.fetchTodoGroup(id);
      const group = res?.todo_group;
      if (group) {
        const index = this.todoGroups.findIndex((g) => g.id === group.id);
        if (index !== -1) {
          this.todoGroups[index] = group;
        } else {
          this.todoGroups.unshift(group);
        }
      }
      return group;
    },

    async createTodoGroup(name: string) {
      const res = await TodoGroupAPI.createTodoGroup({ name });
      const newGroup = { ...res?.todo_group, todos: [] };
      this.todoGroups.push(newGroup);
      this.selectedGroup = newGroup;
      return newGroup;
    },

    async updateTodoGroup(id: number, data: { name?: string; position?: number }) {
      const res = await TodoGroupAPI.updateTodoGroup(id, data);
      const index = this.todoGroups.findIndex((g) => g.id === id);
      if (index !== -1) {
        this.todoGroups[index] = { ...this.todoGroups[index], ...res?.todo_group };
        if (this.selectedGroup?.id === id) {
          this.selectedGroup = { ...this.selectedGroup, ...res?.todo_group };
        }
      }
      return res?.todo_group;
    },

    async deleteTodoGroup(id: number) {
      await TodoGroupAPI.deleteTodoGroup(id);
      this.todoGroups = this.todoGroups.filter((g) => g.id !== id);
      if (this.selectedGroup?.id === id) {
        this.selectedGroup = this.todoGroups.length > 0 ? this.todoGroups[0] : null;
      }
    },

    selectGroup(group: TodoGroup | null) {
      this.selectedGroup = group;
    },

    // Todo actions
    async createTodo(title: string, notes?: string) {
      if (!this.selectedGroup) return;
      const res = await TodoAPI.createTodo(this.selectedGroup.id, { title, notes });
      const newTodo = res?.todo;
      if (this.selectedGroup) {
        this.selectedGroup.todos = [...(this.selectedGroup.todos || []), newTodo];
        this.selectedGroup.todos_count++;
        this.selectedGroup.pending_count++;
      }
      // Update in todoGroups array too
      const groupIndex = this.todoGroups.findIndex((g) => g.id === this.selectedGroup?.id);
      if (groupIndex !== -1) {
        this.todoGroups[groupIndex] = { ...this.selectedGroup };
      }
      return newTodo;
    },

    async updateTodo(id: number, data: { title?: string; notes?: string }) {
      const res = await TodoAPI.updateTodo(id, data);
      const updatedTodo = res?.todo;
      if (this.selectedGroup) {
        const todoIndex = this.selectedGroup.todos.findIndex((t) => t.id === id);
        if (todoIndex !== -1) {
          this.selectedGroup.todos[todoIndex] = updatedTodo;
        }
      }
      return updatedTodo;
    },

    async toggleTodo(id: number) {
      const res = await TodoAPI.toggleTodo(id);
      const updatedTodo = res?.todo;
      if (this.selectedGroup) {
        const todoIndex = this.selectedGroup.todos.findIndex((t) => t.id === id);
        if (todoIndex !== -1) {
          const wasCompleted = this.selectedGroup.todos[todoIndex].completed;
          this.selectedGroup.todos[todoIndex] = updatedTodo;
          // Update counts
          if (wasCompleted && !updatedTodo.completed) {
            this.selectedGroup.completed_count--;
            this.selectedGroup.pending_count++;
          } else if (!wasCompleted && updatedTodo.completed) {
            this.selectedGroup.completed_count++;
            this.selectedGroup.pending_count--;
          }
        }
      }
      // Update in todoGroups array too
      const groupIndex = this.todoGroups.findIndex((g) => g.id === this.selectedGroup?.id);
      if (groupIndex !== -1 && this.selectedGroup) {
        this.todoGroups[groupIndex] = { ...this.selectedGroup };
      }
      return updatedTodo;
    },

    async deleteTodo(id: number) {
      await TodoAPI.deleteTodo(id);
      if (this.selectedGroup) {
        const todo = this.selectedGroup.todos.find((t) => t.id === id);
        if (todo) {
          this.selectedGroup.todos_count--;
          if (todo.completed) {
            this.selectedGroup.completed_count--;
          } else {
            this.selectedGroup.pending_count--;
          }
        }
        this.selectedGroup.todos = this.selectedGroup.todos.filter((t) => t.id !== id);
      }
      // Update in todoGroups array too
      const groupIndex = this.todoGroups.findIndex((g) => g.id === this.selectedGroup?.id);
      if (groupIndex !== -1 && this.selectedGroup) {
        this.todoGroups[groupIndex] = { ...this.selectedGroup };
      }
    },

    async reorderTodos(todoIds: number[]) {
      if (!this.selectedGroup) return;
      await TodoAPI.reorderTodos(this.selectedGroup.id, todoIds);
    },

    updateLocalTodoOrder(todos: Todo[]) {
      if (this.selectedGroup) {
        this.selectedGroup.todos = todos;
        // Update in todoGroups array too
        const groupIndex = this.todoGroups.findIndex((g) => g.id === this.selectedGroup?.id);
        if (groupIndex !== -1) {
          this.todoGroups[groupIndex] = { ...this.selectedGroup };
        }
      }
    },

    resetStates() {
      this.todoGroups = [];
      this.selectedGroup = null;
      this.loading = false;
      this.searching = false;
      this.search = '';
      this.groupsPagination = {};
      this.groupsPage = 1;
      this.loadingMoreGroups = false;
    },
  },
});
