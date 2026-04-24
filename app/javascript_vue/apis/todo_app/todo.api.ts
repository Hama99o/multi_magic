import { http } from '@/services/http.service';

class TodoAPI {
  async fetchTodos(todoGroupId?: number, search = '', completed?: boolean) {
    let url = `/api/v1/todo_app/todos?search=${search}`;
    if (todoGroupId) {
      url += `&todo_group_id=${todoGroupId}`;
    }
    if (completed !== undefined) {
      url += `&completed=${completed}`;
    }
    const res = await http.get(url);
    return res.data;
  }

  async fetchTodo(id: number) {
    const res = await http.get(`/api/v1/todo_app/todos/${id}`);
    return res.data;
  }

  async createTodo(todoGroupId: number, data: { title: string; notes?: string }) {
    const res = await http.post(`/api/v1/todo_app/todos?todo_group_id=${todoGroupId}`, { todo: data });
    return res.data;
  }

  async updateTodo(id: number, data: { title?: string; notes?: string; completed?: boolean; position?: number }) {
    const res = await http.put(`/api/v1/todo_app/todos/${id}`, { todo: data });
    return res.data;
  }

  async toggleTodo(id: number) {
    const res = await http.put(`/api/v1/todo_app/todos/${id}/toggle`);
    return res.data;
  }

  async deleteTodo(id: number) {
    const res = await http.delete(`/api/v1/todo_app/todos/${id}`);
    return res.data;
  }

  async reorderTodos(todoGroupId: number, todoIds: number[]) {
    const res = await http.put(`/api/v1/todo_app/todos/reorder`, {
      todo_group_id: todoGroupId,
      todo_ids: todoIds,
    });
    return res.data;
  }
}

const instance = new TodoAPI();

export default instance;
