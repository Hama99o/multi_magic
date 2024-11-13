import { defineStore } from 'pinia';
import ConversationAPI from '@/apis/conversation.api';
import { isType } from '@babel/types';

export const useConversationStore = defineStore({
  id: 'conversation-store',
  state: () => ({
    isImpersonating: false,
    conversation: {},
    currentConversation: null,
    conversations: [],
    unreadMessagesCount: 0,
    search: '',
    loading: true,
    pagination: {},
    page: 1,
    theme: 'dark',
    isTyping: false,
    typingUser: {},
  }),
  getters: {},
  actions: {
    async fetchConversations() {
      this.loading = true;
      const res = await ConversationAPI.fetchConversations(this.page, this.search);
      this.conversations = res?.conversations;
      this.pagination = {
        current_page: res.meta.pagy.page,
        total_pages: res.meta.pagy.pages,
        total_items: res.meta.total_count,
      };
      this.loading = false;
    },
    async fetchConversationsWithInfiniteScroll() {
      this.loading = true;
      const res = await ConversationAPI.fetchConversations(this.page, this.search);
      this.pagination = {
        current_page: res.meta.pagy.page,
        total_pages: res.meta.pagy.pages,
        total_items: res.meta.total_count,
      };
      this.loading = false;
      return res.conversations
    },
    async fetchConversation(id: number) {
      const res = await ConversationAPI.fetchConversation(id);
      this.conversation = res.conversation;
      this.loading = false;
      return res
    },
    async updateConversation(id: number, userId: number) {
      const res = await ConversationAPI.updateConversation(id, { user_id: userId});
      this.conversation = res.conversation;
      this.loading = false;
      return res.conversation
    },
    async createConversation(user_id: number) {
      const res = await ConversationAPI.createConversation(user_id);
      return res
    },
    async createGroupConversation(user_id: number, name: string) {
      const res = await ConversationAPI.createGroupConversation(user_id, name);
      return res
    },
    async deleteConversation(id: number, userId: number) {
      await ConversationAPI.deleteConversation(id, userId);
    },
    async fetchUnreadMessagesCount() {
      const res = await ConversationAPI.fetchUnreadMessagesCount();
      this.unreadMessagesCount = res.unread_messages_count
    },
    async resetStates() {
      this.conversation = {};
      this.conversations = [];
      this.page = 1
      this.search = ''
      this.pagination = {};
      this.loading = true;
    },
  },
});
