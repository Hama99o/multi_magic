import { defineStore } from 'pinia';
import TagAPI from '@/apis/my_finance_app/tag.api';

export const useTagStore = defineStore({
  id: 'tag-store',
  state: () => ({
    tag: null,
    tags: [],
    childCategories: [],
    search: '',
    pagination: {},
    page: 1,
  }),
  getters: {},
  actions: {
    async fetchTags(search = '', parent_id: number) {
      const res = await TagAPI.fetchTags(search, parent_id);
      if (parent_id) {
        this.childCategories = res.tags
      } else {
        this.tags = res.tags
      }
      return res.tags
    },
    async createTag(text: string, parent_id: number) {
      const res = await TagAPI.createTag( { tag: { name: text, parent_id: parent_id } });
      if (parent_id) {
        this.childCategories.unshift(res.tag)
      } else {
        this.tags.unshift(res.tag)
      }
      return res.tag
    }
  }
})