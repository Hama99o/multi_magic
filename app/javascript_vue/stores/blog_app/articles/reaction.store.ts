import { defineStore } from 'pinia';
import ReactionAPI from '@/apis/blog_app/articles/reaction.api';

export const useReactionStore = defineStore({
  id: 'reaction-store',
  state: () => ({
    reactions: [],
    articleId: null,
  }),
  getters: {
    // Optional: Get a list of reactions filtered by type, for example
    getReactionsByType: (state) => (type) => {
      return state.reactions.filter(reaction => reaction.reaction_type === type);
    }
  },
  actions: {
    // Fetch all reactions for a specific article
    async fetchReactions(articleId) {
      this.articleId = articleId;
      const res = await ReactionAPI.fetchReactions(articleId);
      this.reactions = res.reactions;
      return res.reactions;
    },

    // Create a new reaction for the current article
    async createReaction(articleId, reactionData) {
      const res = await ReactionAPI.createReaction(articleId, { reaction: reactionData });
      const newReaction = res.reaction;

      // Add the new reaction to the state
      this.reactions.push(newReaction);
      return newReaction;
    },

    // Delete a reaction
    async deleteReaction(articleId, reactionId) {
      const res = await ReactionAPI.deleteReaction(articleId, reactionId);
      // Remove the reaction from the state
      this.reactions = this.reactions.filter(reaction => reaction.id !== reactionId);
      return res.reaction;
    }
  }
});
