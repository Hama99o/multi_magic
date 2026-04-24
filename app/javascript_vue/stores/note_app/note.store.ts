import { defineStore } from 'pinia';
import NoteAPI from '@/apis/note_app/note.api';

export const useNoteStore = defineStore({
  id: 'note-store',
  state: () => ({
    note: {},
    notes: [],
    trashesNotes: [],
    tags: [],
    search: '',
    loading: true,
    pagination: {},
    trashesNotesPagination: {},
    selectedTagId: '',
    selectedNote: {},
    page: 1,
  }),
  getters: {},
  actions: {
    async fetchNotes() {
      this.loading = true;
      const res = await NoteAPI.fetchNotes(this.page, this.search, this.selectedTagId);
      this.notes = res?.notes;
      this.pagination = {
        current_page: res.meta.pagy.page,
        total_pages: res.meta.pagy.pages,
        total_items: res.meta.total_count,
      };
      this.loading = false;
    },
    async fetchNewinfinitePage() {
      this.loading = true;
      const res = await NoteAPI.fetchNotes(this.page + 1, this.search);
      this.notes = this.notes.concat(res?.notes)
      this.loading = false;
    },
    async fetchTrashesNotes() {
      this.loading = true;
      const res = await NoteAPI.fetchTrashesNotes(1, this.search);
      this.trashesNotes = res?.notes;
      this.trashesNotesPagination = {
        current_page: res.meta.pagy.page,
        total_pages: res.meta.pagy.pages,
        total_items: res.meta.total_count,
      };
      this.loading = false;
    },
    async fetchNote(id: number) {
      const res = await NoteAPI.fetchNote(id);
      this.note = res.note;
      this.loading = false;
      return res.note
    },
    async updateNote(id: number, data: {}) {
      const res = await NoteAPI.updateNote(id, data);
      // this.note = res.note;
      // this.notes = this.notes.map((n) => {
      //   if (n.id === res.note.id) {
      //     n.title = res.note.title
      //     n.description = res.note.description
      //   }
      //   return n
      // });
    },
    async createNote(data: {}) {
      const res = await NoteAPI.createNote(data);
      this.note = res.note;
      return res.note
    },
    async deleteNote(id: number) {
      await NoteAPI.deleteNote(id);
      await this.fetchTrashesNotes()
      this.notes = this.notes.filter(note => note.id !== id)
    },
    async noteRestore(id: number) {
      await NoteAPI.noteRestore(id);
      await this.fetchTrashesNotes()
    },
    async noteDeletePermanently(id: number) {
      await NoteAPI.noteDeletePermanently(id);
      await this.fetchTrashesNotes()
    },
    async inviteUserToggle(id: number, data: {}) {
      const res = await NoteAPI.inviteUserToggle(id, data);
      this.notes.forEach((note) => {
        if (id === note.id) {
          note.shared_users = res.note.shared_users
          note.shared_count = res.note.shared_count
        }
      })
    },
    async updateSharedUserRights(id: number, data: {}) {
      await NoteAPI.updateSharedUserRights(id, data);
      await this.fetchNotes()
    },
    async fetchTags(search = '') {
      const res = await NoteAPI.fetchTags(search);
      this.tags = res.tags
      return res.tags
    },
    async toggleTag(note: {}, tagId: number) {
      const res = await NoteAPI.toggleTag(note?.id, { tag_id: tagId });
      this.notes.forEach((n) => {
        if (n.id === note.id && n.tags.some(t => tagId === t.id)) {
          n.tags = n.tags.filter((t) => t.id !== tagId)
        } else {
          n.tags.push(res.tag)
        }
      })
      if (note.id === this.note.id) {
        if (this.note.tags.some(t => tagId === t.id)) {
          this.note.tags = this.note.tags.filter((t) => t.id !== tagId)
        } else {
          this.note.tags.push(res.tag)
        }
      }
      return res.tag
    },
    async createTag(noteId: number, text: string) {
      const res = await NoteAPI.createTag(noteId, { text: text });
      this.fetchTags()
      this.notes.forEach((note) => {
        if (note.id === noteId) {
          note.tags.push(res.tag)
          note.tag_ids.push(res.tag.id)
        }
      })
      return res.tag
    },
    async resetStates() {
      this.note = {};
      this.notes = [];
      this.page = 1
      this.search = ''
      this.pagination = {};
      this.loading = true;
    },
  },
});
