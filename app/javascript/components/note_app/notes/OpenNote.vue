<template>
  <div>
    <v-dialog
      max-width="1100"
      v-model="isOpen"
      transition="dialog-bottom-transition"
    >
      <template #default>
        <div class="w-full flex flex-col gap-2 !rounded-md bg-surface" :class="isMobile ? 'p-2' : 'p-6'">
          <v-icon v-if="selectedNote" @click="goToNote(selectedNote.id)" class="cursor-pointer p-4 hover:bg-grey rounded-full p-1">mdi mdi-resize</v-icon>
          <div>
            <!-- <SpeakerButton :text="selectedNote.description" /> -->
            <v-text-field
              v-model="selectedNote.title"
              placeholder="Title"
              type="text"
              variant="solo-filled"
              :disabled="isTrash"
              @update:model-value="updateCurrentNote($event, selectedNote.description)"
            />

            <tiptap-editor
              v-if="selectedNote.description"
              ref="tiptapEditor"
              :record-id="selectedNote.id"
              class="max-h-[500px] rounded-lg bg-background"
              :lastname="currentUser.lastname"
              :content="selectedNote.description"
              :isEditable="!isTrash"
              @on-save="updateCurrentNote(selectedNote.title, $event)"
              autofocus
            />
          </div>

          <v-divider v-if="selectedNote?.tags?.length || selectedNote?.shared_users?.length"></v-divider>

          <div v-if="selectedNote?.tags?.length" class="flex flex-wrap">
            <div v-for="tag in selectedNote.tags" :key="tag.id">
              <v-chip
                :closable="!isTrash"
                :disabled="isTrash"
                @click:close="toggleTagToNote(tag)"
              >
                {{ tag.name }}
              </v-chip>
            </div>
          </div>

          <div v-if="selectedNote?.shared_users?.length" class="flex flex-wrap">
            <AvatarStack :users="selectedNote.shared_users"/>
          </div>

          <v-divider v-if="selectedNote?.tags?.length || selectedNote?.shared_users?.length"></v-divider>

          <!-- Buttons -->
          <div class="flex !justify-between">
            <v-menu>
              <template v-slot:activator="{ props }">
                <v-icon v-if="!isTrash" class="text-primary" icon="mdi-dots-vertical" v-bind="props"></v-icon>
                <div v-else></div>
              </template>
              <v-list class="py-0">
                <div class="flex flex-col">
                  <div
                    class="cursor-pointer hover:bg-grey px-5 py-2"
                    @click.prevent="openInviteUserDialog()"
                  >
                    Invite User
                  </div>
                  <div
                    class="cursor-pointer hover:bg-grey px-5 py-2"
                    @click.prevent="destroyNote()"
                  >
                    Delete Note
                  </div>
                  <div
                    class="cursor-pointer hover:bg-grey px-5 py-2"
                    @click.prevent="openTagDialog()"
                  >
                    Change Tags
                  </div>
                </div>
              </v-list>
            </v-menu>
            <v-icon
              class="text-primary text-xl hover:bg-red-200 p-3"
              icon="mdi mdi-close"
              @click="isOpen = false"
            />
          </div>
        </div>
      </template>
    </v-dialog>

    <invite-user
      ref="inviteUser"
      @add-user="inviteUserWithEmail"
    />

    <tag-dialog
      ref="isTagDialogOpened"
      :note="selectedNoteForTag"
    />
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue';
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
import { useMobileStore } from "@/stores/mobile";
import AvatarStack from '@/components/tools/AvatarStack.vue';

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

const title = ref(selectedNote.value?.title)
const description = ref(selectedNote.value?.description)

const isOpen = ref(false);
const emit = defineEmits(['add-user']);

defineExpose({
  isOpen
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
    toggleTag(selectedNote.value, tag.id)
  } catch (error) {
    console.log(error);
  }
};

const destroyNote = async () => {
  try {
    openPopUp({
      componentName: "pop-up-validation",
      title: ("Are you sure you want to delete this note?"),
      textClose: "No, cancel",
      textConfirm: "Yes, delete this note",
      textLoading: "Deleting ...",
      icon: "mdi-trash-can-outline",
      color: "red",
      customClass: "w-[400px]",
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
  selectedNote.value.title = noteTitle
  selectedNote.value.description = noteDescription

  try {
    await updateNote(selectedNote.value.id, { title: noteTitle, description: noteDescription || ' ' });

  } catch (error) {
    showToast(error.message, 'error');
  }
}, 200);

watch(isOpen, (newNote, oldNote) => {
  if (newNote) {
    router.push({
      name: 'notes',
      query: { note_id: selectedNote.value.id, tag_id: route.query.tag_id, page: route.query.page, search: route.query.search }
    })
  } else {
    notes.value = notes.value.map((n) => {
      if (n.id === selectedNote.value.id) {
        n.title = selectedNote.value.title
        n.description = selectedNote.value.description || '  '
      }
      return n
    });

    router.push({
      name: 'notes',
      query: { tag_id: route.query.tag_id, page: route.query.page, search: route.query.search }
    })
  }
});

const inviteUserWithEmail = async(role, email, UserAction) => {
  try {
    const data = {
      role: role,
      email: email,
      user_action: UserAction
    }
    await inviteUserToggle(selectedNote.value.id, data)
    inviteUser.value.isActive = false
  } catch (errorMessage) {
    showToast(errorMessage.error, 'error');
  }
};

const goToNote = (id) => {
  router.push({ name: 'note', params: { id } })
}
</script>
