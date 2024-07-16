import { http } from '@/services/http.service';

class TagAPI {
  async fetchTags(search = '', parent_id = '') {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.get(`/api/v1/my_finance_app/tags?search=${search}&parent_id=${parent_id}`, { headers });
    return res.data;
  }

  async createTag(data: {}) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.post(`/api/v1/my_finance_app/tags`, data, { headers });
    return res.data;
  }
}

const instance = new TagAPI();

export default instance;
