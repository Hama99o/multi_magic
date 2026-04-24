import { http } from '@/services/http.service';

class NoteAPI {
  async fetchNotes(page = 1, search = '', tag_id = '') {
    const res = await http.get(`/api/v1/note_app/notes?page=${page}&search=${search}&tag_id=${tag_id}`);
    return res.data;
  }
  async fetchTrashesNotes(page = 1, search = '') {
    const res = await http.get(`/api/v1/note_app/notes/trashes?page=${page}&search=${search}`);
    return res.data;
  }
  async fetchNote(id: number) {
    const res = await http.get(`/api/v1/note_app/notes/${id}`);
    return res.data;
  }
  async updateNote(id: number, data: {}) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.put(`/api/v1/note_app/notes/${id}`, data, { headers });
    return res.data;
  }
  async createNote(data: {}) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.post('/api/v1/note_app/notes/', data, { headers });
    return res.data;
  }
  async deleteNote(id: number) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.delete(`/api/v1/note_app/notes/${id}`);
    return res.data;
  }
  async noteDeletePermanently(id: number) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.delete(`/api/v1/note_app/notes/${id}/destroy_permanently`);
    return res.data;
  }
  async noteRestore(id: number) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.put(`/api/v1/note_app/notes/${id}/restore`);
    return res.data;
  }
  async inviteUserToggle(id: number, data: {}) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.put(`/api/v1/note_app/notes/${id}/share_with_user_toggle`, data, { headers });
    return res.data;
  }
  async updateSharedUserRights(id: number, data: {}) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.put(`/api/v1/note_app/notes/${id}/update_shared_user_rights`, data, { headers });
    return res.data;
  }
  async fetchTags(search = '') {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.get(`/api/v1/note_app/notes/tags?search=${search}`, { headers });
    return res.data;
  }
  async toggleTag(id: number, data: {}) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.put(`/api/v1/note_app/notes/${id}/toggle_tag`, data, { headers });
    return res.data;
  }
  async createTag(id: number, data: {}) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.post(`/api/v1/note_app/notes/${id}/create_and_assign_tag`, data, { headers });
    return res.data;
  }
}

const instance = new NoteAPI();

export default instance;
