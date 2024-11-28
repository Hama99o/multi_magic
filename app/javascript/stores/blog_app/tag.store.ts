import { defineStore } from 'pinia';
import TagAPI from '@/apis/blog_app/tag.api';

export const useBlogTagStore = defineStore({
  id: 'tag-store',
  state: () => ({
    tag: null,
    tags: [],
    search: '',
    pagination: {},
    totalPages: 0,
    page: 1,
  }),
  getters: {},
  actions: {
    async fetchTags(search = '') {
      const res = await TagAPI.fetchTags(search);
      this.tags = res.tags
      this.page = res.meta.pagy.page
      this.totalPages = res.meta.pagy.pages
      return res.tags
    },
    async fetchSearchTags(search = '', page = 1) {
      const res = await TagAPI.fetchTags(search, page);
      this.page = res.meta.pagy.page
      this.totalPages = res.meta.pagy.pages
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