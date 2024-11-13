<template>
  <v-table class="m-5">
    <thead>
      <tr>
        <th class="text-left">
          Title
        </th>
        <!-- <th class="text-left">
          Description
        </th> -->
        <th class="text-left">
          Ower
        </th>
        <th class="text-left">
          Share count
        </th>
        <th class="text-left">
          tags
        </th>
        <th class="text-left">
        </th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in notes"
        :key="item.id"
      >
        <td class="truncate px-0">
          <div
            @click="emit('open-note-dialog', item)"
            class="w-full h-full cursor-pointer"
          >
            <div v-if="item?.title" class="w-[45px] h-full flex gap-2 items-center pl-4 whitespace-nowrap">
              {{ item.title }}
            </div>
          </div>
        </td>

        <!-- <td class="truncate px-0">
          <div
            @click="emit('open-note-dialog', item)"
            class="w-full h-full cursor-pointer"
          >
            <div v-if="item?.description" class="w-[45px] h-full flex gap-2 items-center pl-4 whitespace-nowrap">
              {{ getPlainText(item.description) }}
            </div>
          </div>
        </td> -->

        <td class="truncate px-0">
          <div
            @click="!isTrash ? emit('open-note-dialog', item) : null"
            class="w-full h-full cursor-pointer"
          >
            <div v-if="item?.owner?.fullname" class="w-[45px] h-full flex gap-2 items-center pl-4 whitespace-nowrap">
              {{ item?.owner?.fullname }}
            </div>
          </div>
        </td>

        <td class="truncate px-0">
          <div
            @click="emit('open-note-dialog', item)"
            class="w-full h-full cursor-pointer"
          >
          <div  class="w-[45px] h-full flex gap-2 items-center pl-4 whitespace-nowrap">
            {{ item?.shared_count }}
          </div>
          </div>
        </td>

        <td class="truncate px-0 ">
          <div
            @click="emit('open-note-dialog', item)"
            class="w-full h-full cursor-pointer flex align-center"
          >
            <div  v-for="tag in item.tags.slice(0, 2)" :key="tag.id" >
              <v-chip
                class="ma-1 !text-sm"
                :closable="!isTrash"
                :disabled="isTrash"
                @click:close="toggleTagToNote(item, tag)"
              >
                {{ tag.name }}
              </v-chip>
            </div>


            <span v-if="item.tags.length > 2">
              ...
            </span>
          </div>
        </td>

        <td class="!w-[50px] pa-0 cursor-pointer">
          <v-menu >
            <template v-slot:activator="{ props }">
              <v-icon class="text-primary" icon="mdi-dots-vertical" v-bind="props"></v-icon>
            </template>
            <v-list class="py-0">
              <div v-if="isTrash" class="flex flex-col">

                <div
                  class="cursor-pointer hover:bg-grey px-5 py-2"
                  @click.prevent="trashNoteDeletePermanently(item)"
                >
                  Delete Note
                </div>

                <div
                  class="cursor-pointer hover:bg-grey px-5 py-2"
                  @click.prevent="trashNoteRestore(item)"
                >
                  restore
                </div>
              </div>

              <div v-else class="flex flex-col">
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
        </td>
      </tr>
    </tbody>
  </v-table>

  <!-- <note-card :notes="notes" /> -->
  <v-pagination
    v-if="pagination"
    :model-value="pagination.current_page"
    :length="pagination.total_pages"
    :total-visible="6"
    theme="primary"
    variant="text"
    class="my-16 !list-none"
    @update:model-value="fetchNewPage"
  />
</template>

<script setup>
import { storeToRefs } from 'pinia';
import { useNoteStore } from '@/stores/note_app/note.store';
import { showToast } from '@/utils/showToast';
import { usePopUpStore } from "@/stores/pop-up.store";

const { openPopUp, closePopUp } = usePopUpStore();
const { noteRestore, noteDeletePermanently } = useNoteStore();

const { toggleTag, fetchNotes } = useNoteStore();
const emit = defineEmits(['open-invite-user-dialog', 'open-note-dialog', 'open-note-dialog', 'destroy-note']);
const { pagination, page, search } = storeToRefs(useNoteStore());

const props = defineProps({
  noteIndexType: { type: String },
  notes: { type: Array, default: () => [] },
  isTrash: { type: Boolean, default: true },
});

const toggleTagToNote = async(note, tag) => {
  try {
    toggleTag(note, tag.id)
  } catch (error) {
    console.log(error);
  }
};

const fetchNewPage = async(e) => {
  try {
    page.value = e
    await fetchNotes();
  } catch (error) {
    console.log(error);
  }
};

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

</script>
