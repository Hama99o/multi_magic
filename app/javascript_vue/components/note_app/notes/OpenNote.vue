<template>
  <div>
    <v-dialog max-width="1100" v-model="isOpen" transition="dialog-bottom-transition">
      <template #default>
        <v-card class="overflow-hidden" elevation="0">
          <!-- Header Section -->
          <v-card-title class="d-flex align-center justify-space-between pa-4 pa-md-6">
            <div class="d-flex align-center ga-3">
              <v-avatar color="primary" size="40">
                <v-icon color="white">mdi-note-text</v-icon>
              </v-avatar>
              <div>
                <h3 class="text-h6 font-weight-bold">Note Details</h3>
                <p class="text-body-2 text-medium-emphasis ma-0">
                  Last updated: {{ filters.formatDateHoursWithoutSeconds(selectedNote.updated_at) }}
                </p>
              </div>
            </div>

            <!-- Close Button -->
            <v-btn
              icon="mdi-close"
              variant="text"
              size="small"
              @click="
                isOpen = false;
                isLocked = false;
              "
            />
          </v-card-title>

          <v-divider />

          <!-- Action Buttons Bar -->
          <v-card-subtitle class="pa-4 pa-md-6 pb-0">
            <div class="d-flex ga-2 flex-wrap">
              <v-btn
                v-if="selectedNote"
                variant="outlined"
                size="small"
                prepend-icon="mdi-resize"
                @click="goToNote(selectedNote.id)"
              >
                <span class="d-none d-sm-inline">Full View</span>
              </v-btn>

              <v-btn
                v-if="selectedNote && !isTrash"
                variant="outlined"
                size="small"
                :prepend-icon="isLocked ? 'mdi-lock' : 'mdi-lock-open'"
                :color="isLocked ? 'error' : 'success'"
                @click="toggleLock"
              >
                <span class="d-none d-sm-inline">{{ isLocked ? 'Locked' : 'Unlocked' }}</span>
              </v-btn>

              <v-btn
                v-if="selectedNote"
                variant="outlined"
                size="small"
                prepend-icon="mdi-content-copy"
                color="info"
                @click="copyNoteContent"
              >
                <span class="d-none d-sm-inline">Copy</span>
              </v-btn>

              <v-spacer />

              <!-- Actions Menu -->
              <v-menu v-if="!isTrash" location="bottom end">
                <template v-slot:activator="{ props }">
                  <v-btn icon="mdi-dots-vertical" variant="text" size="small" v-bind="props" />
                </template>
                <v-list density="compact">
                  <v-list-item
                    prepend-icon="mdi-account-plus"
                    title="Invite User"
                    @click="openInviteUserDialog"
                  />
                  <v-list-item prepend-icon="mdi-tag" title="Manage Tags" @click="openTagDialog" />
                  <v-divider />
                  <v-list-item
                    prepend-icon="mdi-delete"
                    title="Delete Note"
                    class="text-error"
                    @click="destroyNote"
                  />
                </v-list>
              </v-menu>
            </div>
          </v-card-subtitle>

          <!-- Content Section -->
          <v-card-text class="pa-4 pa-md-6">
            <!-- Title Input -->
            <v-text-field
              v-model="selectedNote.title"
              placeholder="Enter note title..."
              variant="outlined"
              density="comfortable"
              :disabled="isTrash || isLocked"
              @update:model-value="updateCurrentNote($event, selectedNote.description)"
              class="mb-4"
            />

            <!-- Editor -->
            <div class="editor-container">
              <tiptap-editor
                v-if="selectedNote.description"
                ref="tiptapEditor"
                :key="editorKey"
                :record-id="selectedNote.id"
                class="editor-content rounded-lg border"
                :lastname="currentUser.lastname"
                :content="selectedNote.description"
                :is-editable="isEditable"
                @on-save="updateCurrentNote(selectedNote.title, $event)"
                autofocus
              />
            </div>
          </v-card-text>

          <!-- Tags and Shared Users Section -->
          <v-card-text
            v-if="selectedNote?.tags?.length || selectedNote?.shared_users?.length"
            class="pa-4 pa-md-6 pt-0"
          >
            <!-- Tags -->
            <div v-if="selectedNote?.tags?.length" class="mb-4">
              <p class="text-body-2 text-medium-emphasis mb-2">Tags:</p>
              <div class="d-flex ga-2 flex-wrap">
                <v-chip
                  v-for="tag in selectedNote.tags"
                  :key="tag.id"
                  :closable="!isTrash"
                  :disabled="isTrash"
                  color="primary"
                  variant="outlined"
                  size="small"
                  @click:close="toggleTagToNote(tag)"
                >
                  {{ tag.name }}
                </v-chip>
              </div>
            </div>

            <!-- Shared Users -->
            <div v-if="selectedNote?.shared_users?.length">
              <p class="text-body-2 text-medium-emphasis mb-2">Shared with:</p>
              <AvatarStack :users="selectedNote.shared_users" />
            </div>
          </v-card-text>
        </v-card>
      </template>
    </v-dialog>

    <invite-user ref="inviteUser" @add-user="inviteUserWithEmail" />

    <tag-dialog ref="isTagDialogOpened" :note="selectedNoteForTag" />
  </div>
</template>

<script setup>
import { ref, watch, computed } from 'vue';
import InviteUser from '@/components/note_app/notes/InviteUser.vue';
import { useNoteStore } from '@/stores/note_app/note.store';
import { debounce } from 'lodash';
import { showToast } from '@/utils/showToast';
import { storeToRefs } from 'pinia';
import { usePopUpStore } from '@/stores/pop-up.store';
import TagDialog from '@/components/note_app/notes/TagDialog.vue';
import { useRouter, useRoute } from 'vue-router';
import UserAvatar from '@/components/tools/Avatar.vue';
import TiptapEditor from '@/components/richtext/TiptapEditor.vue';
import { useUserStore } from '@/stores/user.store';
import { useMobileStore } from '@/stores/mobile';
import AvatarStack from '@/components/tools/AvatarStack.vue';
import filters from '@/tools/filters';

const { isMobile } = storeToRefs(useMobileStore());
const props = defineProps({
  isTrash: { type: Boolean, default: true },
});

const { currentUser } = storeToRefs(useUserStore());
const { updateNote, deleteNote, toggleTag } = useNoteStore();
const { inviteUserToggle } = useNoteStore();
const { notes, selectedNote } = storeToRefs(useNoteStore());
const { openPopUp, closePopUp } = usePopUpStore();
const router = useRouter();
const route = useRoute();

const selectedNoteForTag = ref(null);
const inviteUser = ref(null);
const isTagDialogOpened = ref(null);

const title = ref(selectedNote.value?.title);
const description = ref(selectedNote.value?.description);

const isOpen = ref(false);
const isLocked = ref(false);
const editorKey = ref(0);

defineEmits(['add-user']);

defineExpose({
  isOpen,
});

const openInviteUserDialog = () => {
  inviteUser.value.isActive = true;
};

const openTagDialog = () => {
  selectedNoteForTag.value = selectedNote.value;
  isTagDialogOpened.value.isActive = true;
};

const toggleTagToNote = async (tag) => {
  try {
    toggleTag(selectedNote.value, tag.id);
  } catch (error) {
    console.log(error);
  }
};

const destroyNote = async () => {
  try {
    openPopUp({
      componentName: 'pop-up-validation',
      title: 'Are you sure you want to delete this note?',
      textClose: 'No, cancel',
      textConfirm: 'Yes, delete this note',
      textLoading: 'Deleting ...',
      icon: 'mdi-trash-can-outline',
      color: 'red',
      customClass: 'w-[400px]',
      showClose: false,
      async confirm() {
        await deleteNote(selectedNote.value.id);
        isOpen.value = false;
        notes.value = notes.value.filter((n) => n.id !== selectedNote.value.id);
        closePopUp();
        showToast(`${selectedNote.value.title} note deleted successfully`, 'primary');
      },
    });
  } catch (error) {
    console.log(error);
  }
};

const updateCurrentNote = debounce(async (noteTitle, noteDescription) => {
  selectedNote.value.title = noteTitle;
  selectedNote.value.description = noteDescription;

  try {
    await updateNote(selectedNote.value.id, {
      title: noteTitle,
      description: noteDescription || ' ',
    });
  } catch (error) {
    showToast(error.message, 'error');
  }
}, 200);

watch(isOpen, (newNote, oldNote) => {
  if (newNote) {
    router.push({
      name: 'notes',
      query: {
        note_id: selectedNote.value.id,
        tag_id: route.query.tag_id,
        page: route.query.page,
        search: route.query.search,
      },
    });
  } else {
    notes.value = notes.value.map((n) => {
      if (n.id === selectedNote.value.id) {
        n.title = selectedNote.value.title;
        n.description = selectedNote.value.description || '  ';
      }
      return n;
    });

    router.push({
      name: 'notes',
      query: { tag_id: route.query.tag_id, page: route.query.page, search: route.query.search },
    });
  }
});

const inviteUserWithEmail = async (role, email, UserAction) => {
  try {
    const data = {
      role: role,
      email: email,
      user_action: UserAction,
    };
    await inviteUserToggle(selectedNote.value.id, data);
    inviteUser.value.isActive = false;
  } catch (errorMessage) {
    showToast(errorMessage.error, 'error');
  }
};

const goToNote = (id) => {
  router.push({ name: 'note', params: { id } });
};

const toggleLock = () => {
  isLocked.value = !isLocked.value;
  editorKey.value += 1; // Force re-render of the editor
};

const isEditable = computed(() => !props.isTrash && !isLocked.value);

const copyNoteContent = async () => {
  try {
    // Get plain text content from the note description
    const tempDiv = document.createElement('div');
    tempDiv.innerHTML = selectedNote.value.description;
    const plainText = tempDiv.textContent || tempDiv.innerText || '';

    await navigator.clipboard.writeText(plainText);
    showToast('Note content copied to clipboard', 'success');
  } catch (error) {
    console.error('Failed to copy content:', error);
    showToast('Failed to copy content', 'error');
  }
};
</script>

<style scoped>
.editor-container {
  position: relative;
}

.editor-content {
  min-height: 300px;
  max-height: 500px;
  background: rgb(var(--v-theme-surface));
  transition: all 0.3s ease;
  overflow-x: hidden;
  width: 100%;
  word-wrap: break-word;
  overflow-wrap: break-word;
}

.editor-content:focus-within {
  border-color: rgb(var(--v-theme-primary));
  box-shadow: 0 0 0 2px rgba(var(--v-theme-primary), 0.2);
}

/* Responsive adjustments */

/* Smooth transitions for hover states */
.v-btn {
  transition: all 0.2s ease;
}

.v-chip {
  transition: all 0.2s ease;
}

.v-chip:hover {
  transform: translateY(-1px);
}
</style>
