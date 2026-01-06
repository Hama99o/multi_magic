import { http } from '@/services/http.service';

class TodoGroupAPI {
  async fetchTodoGroups(page = 1, search = '') {
    const res = await http.get(`/api/v1/todo_app/todo_groups?page=${page}&search=${search}`);
    return res.data;
  }

  async fetchTodoGroup(id: number) {
    const res = await http.get(`/api/v1/todo_app/todo_groups/${id}`);
    return res.data;
  }

  async createTodoGroup(data: { name: string }) {
    const res = await http.post('/api/v1/todo_app/todo_groups', { todo_group: data });
    return res.data;
  }

  async updateTodoGroup(id: number, data: { name?: string; position?: number }) {
    const res = await http.put(`/api/v1/todo_app/todo_groups/${id}`, { todo_group: data });
    return res.data;
  }

  async deleteTodoGroup(id: number) {
    const res = await http.delete(`/api/v1/todo_app/todo_groups/${id}`);
    return res.data;
  }
}

const instance = new TodoGroupAPI();

export default instance;
