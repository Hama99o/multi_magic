<template>
  <notes-index-option
    :notes="notes"
    :note-index-type="currentUser?.note_index_type"
    :currentUser="currentUser"
    :isTrash="route?.query?.page === 'trash'"
    :trashesNotes="trashesNotes"
    @createNewNote="createNewNote"
    @fetchTagNotes="fetchTagNotes"
    @searchNote="searchNote"
    @openTrashDialog="openTrashDialog"
    @toggleView="toggleView"
    @item-restore="noteRestore"
    @trash-delete-permanently="noteDeletePermanently"
  />

  <open-note ref="isNoteOpened" :isTrash="false" />

  <!-- <note-trashes
    ref="isNoteTrashesDialogOpened"
    name="note"
    :trashesItems="trashesNotes"
    @item-restore="noteRestore"
    @trash-delete-permanently="noteDeletePermanently"
  /> -->
</template>

<script setup>
import NotesIndexOption from '@/components/note_app/notes/NotesIndexOption.vue';
import { storeToRefs } from 'pinia';
import { useNoteStore } from '@/stores/note_app/note.store';
import { onMounted, ref, computed } from 'vue';
import OpenNote from '@/components/note_app/notes/OpenNote.vue';
import NoteTrashes from '@/components/dialogs/trashItemsDialog.vue';
import { useRoute, useRouter } from 'vue-router';
import { useUserStore } from '@/stores/user.store';
import { useNoteTagStore } from '@/stores/note_app/tag.store';

const {
  fetchNotes,
  fetchTrashesNotes,
  resetStates,
  createNote,
  fetchNote,
  noteRestore,
  noteDeletePermanently,
} = useNoteStore();
const { updateUser } = useUserStore();
const { fetchTags } = useNoteTagStore();

const { notes, trashesNotes, search, selectedTagId, page, selectedNote } = storeToRefs(
  useNoteStore(),
);
const { currentUser } = storeToRefs(useUserStore());

const route = useRoute();
const router = useRouter();

const isNoteOpened = ref(null);
const isNoteTrashesDialogOpened = ref(null);

onMounted(async () => {
  await onMountedMethod();
});

const onMountedMethod = async () => {
  try {
    await resetStates();
    if (route?.query?.tag_id) {
      selectedTagId.value = route?.query?.tag_id;
    }

    if (route?.query?.search) {
      search.value = (typeof route?.query?.search === 'string' ? route.query.search : '') || '';
    } else {
      search.value = '';
    }

    if (route?.query?.page === 'trash') {
      isNoteTrashesDialogOpened.value = true;
    }

    fetchTags();
    await fetchNotes();
    await fetchTrashesNotes();

    if (route?.query?.note_id) {
      const note = await fetchNote(route?.query?.note_id);
      selectedNote.value = note;
      openNoteDialog(note);
    }
  } catch (error) {
    console.log(error);
  }
};

const fetchTagNotes = async (tag) => {
  page.value = 1;
  selectedTagId.value = tag.id;
  search.value = (typeof route?.query?.search === 'string' ? route.query.search : '') || '';

  router.push({
    name: 'notes',
    query: {
      tag_id: tag.id,
      search: search.value,
      page: 'all_notes',
    },
  });
  notes.value = [];
  await fetchNotes();
};

const openNoteDialog = (note) => {
  selectedNote.value = note;
  isNoteOpened.value.isOpen = true;
};

const openTrashDialog = async () => {
  isNoteTrashesDialogOpened.value = true;
  selectedTagId.value = null;
  router.push({
    name: 'notes',
    query: {
      search: route?.query?.search,
      page: 'trash',
    },
  });
  await fetchTrashesNotes();
};

const toggleView = async () => {
  try {
    let type = 'table';
    if (currentUser.value?.note_index_type == 'card_grid') {
      type = 'card_list';
    } else if (currentUser.value?.note_index_type == 'card_list') {
      type = 'table';
    } else {
      type = 'card_grid';
    }
    await updateUser(currentUser.value.id, { note_index_type: type });
    await onMountedMethod();
  } catch (error) {
    console.log(error);
  }
};

const createNewNote = async () => {
  try {
    const data = {
      title: '',
      description: '<p></p>',
      tag_id: route?.query?.tag_id,
    };
    const note = await createNote(data);
    notes.value.unshift(note);
    openNoteDialog(note);
  } catch (error) {
    console.log(error);
  }
};

const searchNote = async (e) => {
  try {
    page.value = 1;
    // Don't overwrite search.value - it's already set by v-model in the child

    router.push({
      name: 'notes',
      query: {
        tag_id: route?.query?.tag_id,
        search: e || '',
        page: route?.query?.page,
      },
    });
    if (route?.query?.page == 'trash') {
      await fetchTrashesNotes();
    } else {
      await fetchNotes();
    }
  } catch (error) {
    console.log(error);
  }
};
</script>
