import { http } from '@/services/http.service';

class ConversationAPI {
  async fetchConversations(page = 1, search = '') {
    try {
      const res = await http.get(`/api/v1/conversations?page=${page}&search=${search}`);
      return res.data;
    } catch (error) {
      return error;
    }
  }
  async fetchConversation(id: number) {
    try {
      const res = await http.get(`/api/v1/conversations/${id}`);
      return res.data;
    } catch (error) {
      return error;
    }
  }
  async updateConversation(id: number, data: object) {
    try {
      const res = await http.put(`/api/v1/conversations/${id}`, data);
      return res.data;
    } catch (error) {
      return error;
    }
  }
  async fetchUnreadMessagesCount() {
    try {
      const res = await http.get(`/api/v1/conversations/unread_messages_count`);
      return res.data;
    } catch (error) {
      return error;
    }
  }
  async createConversation(user_id: number) {
    try {
      const headers = { 'Content-Type': 'multipart/form-data' };
      const res = await http.post(`/api/v1/conversations`, { user_id: user_id }, { headers });
      return res.data;
    } catch (error) {
      return error;
    }
  }
  async createGroupConversation(user_ids: number, name: string) {
    try {
      const headers = { 'Content-Type': 'multipart/form-data' };
      const res = await http.post(`/api/v1/conversations`, { user_ids: user_ids, is_group: true, name: name }, { headers });
      return res.data;
    } catch (error) {
      return error;
    }
  }
  async deleteConversation(id: number, userId: number) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.delete(`/api/v1/conversations/${id}?user_id=${userId}`);
    return res.data;
  }
}

const instance = new ConversationAPI();

export default instance;
