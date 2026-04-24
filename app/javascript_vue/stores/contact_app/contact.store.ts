import { defineStore } from 'pinia';
import ContactAPI from '@/apis/contact_app/contact.api';

export const useContactStore = defineStore({
  id: 'contact-store',
  state: () => ({
    contact: {},
    contacts: [],
    trashesContacts: [],
    tags: [],
    search: '',
    loading: true,
    pagination: {},
    trashesContactsPagination: {},
    page: 1,
  }),
  getters: {},
  actions: {
    async fetchContacts() {
      this.loading = true;
      const res = await ContactAPI.fetchContacts(this.page, this.search);
      this.contacts = res?.contacts;
      this.pagination = {
        current_page: res.meta.pagy.page,
        total_pages: res.meta.pagy.pages,
        total_items: res.meta.total_count,
      };
      this.loading = false;
    },
    async fetchTrashesContacts() {
      this.loading = true;
      const res = await ContactAPI.fetchTrashesContacts(1, this.search);
      this.trashesContacts = res?.contacts;
      this.trashesContactsPagination = {
        current_page: res.meta.pagy.page,
        total_pages: res.meta.pagy.pages,
        total_items: res.meta.total_count,
      };
      this.loading = false;
    },
    async fetchContact(id: number) {
      const res = await ContactAPI.fetchContact(id);
      this.contact = res.contact;
      this.loading = false;
      return res.contact
    },
    async updateContact(data: {}) {
      const res = await ContactAPI.updateContact(data?.contact?.id, data);
      // this.contact = res.contact;
    },
    async exportContact(id: number) {
      const res = await ContactAPI.exportContact(id);
      return res
    },
    async importContact(data) {
      const res = await ContactAPI.importContact(data);
      return res
    },
    async exportMultipleContacts(ids) {
      const res = await ContactAPI.exportMultipleContacts(ids);
      return res
    },
    async createContact(data: {}) {
      const res = await ContactAPI.createContact(data);
      this.contact = res.contact;
      return res.contact
    },
    async deleteContact(id: number) {
      await ContactAPI.deleteContact(id);
      await this.fetchTrashesContacts()
      this.contacts = this.contacts.filter(contact => contact.id !== id)
    },
    async contactRestore(id: number) {
      await ContactAPI.contactRestore(id);
      await this.fetchTrashesContacts()
    },
    async contactDeletePermanently(id: number) {
      await ContactAPI.contactDeletePermanently(id);
      await this.fetchTrashesContacts()
    },
    async resetStates() {
      this.contact = {};
      this.contacts = [];
      this.page = 1
      this.search = ''
      this.pagination = {};
      this.loading = true;
    },
  },
});
