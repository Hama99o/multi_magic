<template>
  <v-infinite-scroll
    v-if="notes?.length"
    class="px-2 md:!px-0 overflow-hidden"
    :items="notes"
    :onLoad="load"
  >
    <div :class="isMobile || noteIndexType != 'card_grid' ? 'list-masonry' : 'masonry sm:masonry-sm md:masonry-md'">
      <v-card
        v-for="(item, i) in notes" :key="i"
        hover
        max-width="750"
        @click="openNoteDialog(item)"
        class="d-flex flex-column just mx-auto mb-[0.7em] max-h-[500px]"
      >
        <div :class="openNoteId == item.id ? 'invisible overflow-hidden' : ''" class="flex flex-col gap-1 m-3">
          <div class="truncate font-semibold bg-background p-2" v-html="highlight(item.title || 'Untitled Note')">
          </div>
          <span class="note-container whitespace-normal line-clamp-22 line-clamp-[22]" v-html="highlight(item.description)" />
        </div>

        <div v-if="openNoteId != item.id" class="flex flex-col gap-2">
          <div v-if="item.tags?.length" class="flex flex-wrap mt-5">
            <div  v-for="tag in item.tags.filter((x) => item.tag_ids.includes(x.id)).slice(0, 4)" :key="tag.id">
              <v-chip
                class="ma-1"
                :closable="!isTrash"
                :disabled="isTrash"
                @click:close="toggleTagToNote(item, tag)"
              >
                {{ tag.name }}
              </v-chip>
            </div>
          </div>

          <div v-if="item?.shared_users?.length" class="flex flex-wrap ml-1">
            <AvatarStack :users="item.shared_users"/>
          </div>
        </div>

        <v-card-actions>
          <v-menu v-if="openNoteId != item.id">
            <template v-slot:activator="{ props }">
              <v-icon v-if="!isTrash" class="text-primary" icon="mdi-dots-vertical" v-bind="props"></v-icon>
            </template>
            <v-list class="py-0">
              <div class="flex flex-col">
                <div
                  class="cursor-pointer hover:bg-grey px-5 py-2"
                  @click.prevent="emit('open-invite-user-dialog', item)"
                >
                  Invite User
                </div>
                <div
                  class="cursor-pointer hover:bg-grey px-5 py-2"
                  @click.prevent="emit('destroy-note', item)"
                >
                  Delete Note
                </div>
                <div
                  class="cursor-pointer hover:bg-grey px-5 py-2"
                  @click.prevent="emit('open-tag-dialog', item)"
                >
                  Change tags
                </div>
              </div>
            </v-list>
          </v-menu>
        </v-card-actions>
        <div v-if="isTrash" class="flex justify-between mx-1">
          <v-btn
            icon
            size="small"
            @click.stop="trashNoteDeletePermanently(item)"
          >
            <v-icon class="text-primary" size="32" :icon="'mdi mdi-delete'" />
          </v-btn>

          <v-btn
            icon
            size="small"
            @click.stop="trashNoteRestore(item)"
          >
            <v-icon class="text-primary" size="32" :icon="'mdi mdi-restore'" />
          </v-btn>
        </div>
      </v-card>
    </div>
    <template v-slot:empty>
      <!-- <span class="my-12">No more notes!</span> -->
    </template>
  </v-infinite-scroll>

  <div
    v-if="!notes?.length"
    class="flex justify-center items-center pt-[300px]"
  >
    <span class="my-12">No more notes!</span>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { storeToRefs } from 'pinia';
import { useNoteStore } from '@/stores/note_app/note.store';
import UserAvatar from '@/components/tools/Avatar.vue';
import { usePopUpStore } from "@/stores/pop-up.store";
import { showToast } from '@/utils/showToast';
import { useRoute } from 'vue-router';
import AvatarStack from '@/components/tools/AvatarStack.vue';
import { useMobileStore } from "@/stores/mobile";

const { isMobile } = storeToRefs(useMobileStore());
const { openPopUp, closePopUp } = usePopUpStore();
const { page, pagination, selectedNote, search } = storeToRefs(useNoteStore());
const { noteRestore, noteDeletePermanently } = useNoteStore();

const emit = defineEmits(['open-invite-user-dialog', 'open-tag-dialog', 'open-note-dialog', 'destroy-note', 'item-restore', 'trash-delete-permanently']);

const props = defineProps({
  noteIndexType: { type: String },
  notes: { type: Array, default: () => [] },
  isTrash: { type: Boolean, default: true },
});

const { toggleTag, fetchNewinfinitePage } = useNoteStore();

const route = useRoute();

const openNoteDialog = (note) => {
  selectedNote.value = note
  emit('open-note-dialog', note)
}
const toggleTagToNote = async(note, tag) => {
  try {
    toggleTag(note, tag.id)
  } catch (error) {
    console.log(error);
  }
};

const updateCollaborators = async(user, note) => {
  try {
    openPopUp({
      componentName: "pop-up-share-user-config",
      title: ("Collaborators"),
      user: user,
      note: note,
      color: "red",
      customClass: "w-[400px]",
      showClose: false,
    });
  } catch (error) {
    console.log(error);
  }
};

const openNoteId = computed(() => {
  return route.query.note_id
})

const fetchNewPage = async(e) => {
  try {
    page.value = e
    await fetchNewinfinitePage();
  } catch (error) {
    console.log(error);
  }
};

const load = async ({ done }) => {
  if (page.value < pagination.value.total_pages) {
    try {
      await fetchNewPage(page.value)
      done('ok')
      page.value += 1
    } catch (error) {
      done('error')
    }
  }
  else {
    done('empty')
  }
}

const trashNoteRestore = async(trashesItem) => {
  await noteRestore(trashesItem.id)
  showToast(`${trashesItem.title || trashesItem.item || trashesItem.contact_name} ${trashesItem.name} restore successfully`, 'success');
}

const trashNoteDeletePermanently = async(trashesItem) => {
  try {
    openPopUp({
      componentName: "pop-up-validation",
      title: (`Are you sure you want to delete permanently this ${trashesItem.title} ?`),
      textClose: "No, cancel",
      textConfirm: `Yes, delete this ${trashesItem.title}`,
      textLoading: "Deleting ...",
      icon: "mdi-trash-can-outline",
      color: "red",
      customClass: "w-[400px]",
      showClose: false,
      async confirm() {
        await noteDeletePermanently(trashesItem.id)
        closePopUp();
        showToast(`${trashesItem.title || trashesItem.item || trashesItem.contact_name || 'Note '} deleted successfully`, 'error');
      },
    });
  } catch (error) {
    console.log(error);
  }
};

const highlight = ( data ) => {
  if (search.value?.length >= 3) {
    const pattern = new RegExp( search.value, 'i' );
    const highlightedData = data.toLowerCase().replace(/<[^>]*>/g, '').replace(
      pattern,
      `<span class="hl-search">${search.value}</span>`
    );
    return highlightedData;
  } else {
    return data
  }
}
</script>
