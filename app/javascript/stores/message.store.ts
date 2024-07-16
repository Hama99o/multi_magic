import { defineStore } from 'pinia';
import MessageAPI from '@/apis/message.api';

export const useMessageStore = defineStore({
  id: 'message-store',
  state: () => ({
    isImpersonating: false,
    message: {},
    currentMessage: null,
    messages: [],
    search: '',
    loading: true,
    pagination: {},
    page: 1,
    theme: 'dark'
  }),
  getters: {},
  actions: {
    async fetchMessages(conversation_id: number) {
      this.loading = true;
      const res = await MessageAPI.fetchMessages(conversation_id, this.page, this.search);
      this.messages = res?.messages?.reverse();
      this.pagination = {
        current_page: res.meta.pagy.page,
        total_pages: res.meta.pagy.pages,
        total_items: res.meta.total_count,
      };
      this.loading = false;
      return res?.messages
    },
    async fetchGlobalMessages(conversation_id: number, page: number, search: string) {
      this.loading = true;
      const res = await MessageAPI.fetchMessages(conversation_id, page, search);
      this.loading = false;
      return res
    },
    async fetchMessage(id: number) {
      await this.resetStates();
      const res = await MessageAPI.fetchMessage(id);
      this.message = res.message;
      this.loading = false;

    },
    async createMessage(conversation_id: number, data: {}) {
      const res = await MessageAPI.createMessage(conversation_id, data);
      return res
    },
    async deleteMessage(id: number) {
      await MessageAPI.deleteMessage(id);
    },
    async messageDeletePermanently(id: number) {
      await MessageAPI.messageDeletePermanently(id);
    },
    async resetStates() {
      this.message = {};
      this.messages = [];
      this.page = 1
      this.search = ''
      this.pagination = {};
      this.loading = true;
    },
  },
});
