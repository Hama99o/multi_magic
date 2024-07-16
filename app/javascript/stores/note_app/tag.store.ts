import { defineStore } from 'pinia';
import TagAPI from '@/apis/note_app/tag.api';

export const useTagStore = defineStore({
  id: 'tag-store',
  state: () => ({
    tag: null,
    tags: [],
    search: '',
    pagination: {},
    page: 1,
  }),
  getters: {},
  actions: {
    async fetchTags(search = '') {
      const res = await TagAPI.fetchTags(search);
      this.tags = res.tags
      return res.tags
    },
    async fetchSearchTags(search = '') {
      const res = await TagAPI.fetchTags(search);
      return res.tags
    },
    async createTag(text: string) {
      const res = await TagAPI.createTag( { tag: { name: text } });
      return res.tag
    },
    async updateTag(id: string, data: {}) {
      const res = await TagAPI.updateTag(id, data);
      return res.tag
    },
    async deleteTag(id: string) {
      const res = await TagAPI.deleteTag(id);
      return res.tag
    }
  }
})