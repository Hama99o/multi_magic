import { http } from '@/services/http.service';

class ContactAPI {
  async fetchContacts(page = 1, search = '') {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.get(`/api/v1/contact_app/contacts?page=${page}&search=${search}`, { headers });
    return res.data;
  }

  async createContact(data: {}) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.post(`/api/v1/contact_app/contacts`, data, { headers });
    return res.data;
  }

  async updateContact(id: number, data: {}) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.put(`/api/v1/contact_app/contacts/${id}`, data, { headers });
    return res.data;
  }

  async deleteContact(id: number) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.delete(`/api/v1/contact_app/contacts/${id}`);
    return res.data;
  }

  async contactDeletePermanently(id: number) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.delete(`/api/v1/contact_app/contacts/${id}/destroy_permanently`);
    return res.data;
  }
  async contactRestore(id: number) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.put(`/api/v1/contact_app/contacts/${id}/restore`);
    return res.data;
  }

  async exportContact(id: number) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.get(`/api/v1/contact_app/contacts/${id}/export_vcard`);
    return res.data;
  }

  async exportMultipleContacts(ids) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.get(`/api/v1/contact_app/contacts/export_multiple_contacts`, {
      params: {
        ids: ids
      }
    });
    return res.data;
  }

  async importContact(data) {
    const headers = { 'Content-Type': 'multipart/form-data' };
    const res = await http.post(`/api/v1/contact_app/contacts/import_vcard`, data);
    return res.data;
  }

  async fetchTrashesContacts(page = 1, search = '') {
    const res = await http.get(`/api/v1/contact_app/contacts/trashes?page=${page}&search=${search}`);
    return res.data;
  }
}

const instance = new ContactAPI();

export default instance;
