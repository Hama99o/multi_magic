import { http } from '@/services/http.service';

class MessageAPI {
  async fetchMessages(conversation_id: number, page = 1, search = '') {
    try {
      const res = await http.get(`/api/v1/conversations/${conversation_id}/messages?page=${page}&search=${search}`);
      return res.data;
    } catch (error) {
      return error;
    }
  }
  async fetchMessage(id: number) {
    try {
      const res = await http.get(`/api/v1/messages/${id}`);
      return res.data;
    } catch (error) {
      return error;
    }
  }
  async createMessage(conversation_id: number, data: {}) {
    try {
      const headers = { 'Content-Type': 'multipart/form-data' };
      const res = await http.post(`/api/v1/conversations/${conversation_id}/messages`, data, { headers });
      return res.data;
    } catch (error) {
      return error;
    }
  }
  async deleteMessage(id: number) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.delete(`/api/v1/messages/${id}`);
    return res.data;
  }
  async messageDeletePermanently(id: number) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.delete(`/api/v1/messages/${id}/destroy_permanently`);
    return res.data;
  }
}

const instance = new MessageAPI();

export default instance;
