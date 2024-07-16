<template>
  <div>
    <v-dialog max-width="600" v-model="isActive">
      <template #default>
        <div class="w-full flex flex-col p-6 gap-8 bg-white">
          <!-- Icon and text -->
          <div class="flex flex-col items-center gap-4 mb-5">
            <!-- icon -->
            <v-icon
              icon="mdi mdi-trash-can-outline"
              height="52"
              width="52"
            />

            <div class="flex flex-grow justify-center ml-6">
              <p
                class="font-medium text-xl text-fakeBlack line-clamp-1"
              >
                Deleted {{`${name}s`}}
              </p>
            </div>
          </div>

          <div
            v-if="trashesItems.length"
            class="flex gap-3 flex-row justify-between border-b text-fake-black text-sm items-center cursor-pointer hover:bg-[#F6F6F6]"
            v-for="trashesItem in trashesItems"
            :key="trashesItem.id"
          >
            <p class="ml-1 flex basis-1/3 truncate">
              Title: {{ trashesItem.title || trashesItem.item || trashesItem.contact_name }}
            </p>

            <p
              class="min-w-[92px]"
            >
              Deleted at: {{ moment(trashesItem.deleted_at, "YYYY-MM-DD HH:mm:ss [UTC]").format("dddd Do MMMM, h:mm a") }}
            </p>

            <v-tooltip :text="`Restore ${props.name}`" location="top">
              <template v-slot:activator="{ props }">
                <v-icon class="text-primary" v-bind="props" icon="mdi mdi-restore" @click="trashNoteRestore(trashesItem)"></v-icon>
              </template>
            </v-tooltip>

            <v-tooltip :text="`Delete permanently ${props.name}`" location="top">
              <template v-slot:activator="{ props }">
                <v-icon class="text-primary" v-bind="props" icon="mdi mdi-delete" @click="trashNoteDeletePermanently(trashesItem)"></v-icon>
              </template>
            </v-tooltip>
          </div>

          <div v-else class="flex justify-center">
            No trash {{ `${props.name}s` }} are available at the moment.
          </div>

          <!-- Buttons -->
          <div class="flex flex-col items-start gap-3 self-stretch lg:!flex-row">
            <v-btn
              variant="outlined"
              color="fakeBlack"
              class="normal-case text-xs w-full lg:!flex-1"
              text="cancel"
              @click="isActive = false"
            />
          </div>
        </div>
      </template>
    </v-dialog>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import moment from 'moment';
const { openPopUp, closePopUp } = usePopUpStore();
import { usePopUpStore } from "@/stores/pop-up.store";
import { showToast } from '@/utils/showToast';

const props = defineProps({
  name: { type: String, default: '' },
  trashesItems: { type: Array, default: () => [] },

});

const isActive = ref(false)
const emit = defineEmits(['item-restore', 'trash-delete-permanently'])

const trashNoteRestore = async(trashesItem) => {
  emit('item-restore', trashesItem.id)
  showToast(`${trashesItem.title || trashesItem.item || trashesItem.contact_name} ${props.name} restore successfully`, 'success');
}

const trashNoteDeletePermanently = async(trashesItem) => {
  try {
    openPopUp({
      componentName: "pop-up-validation",
      title: (`Are you sure you want to delete permanently this ${props.name} ?`),
      textClose: "No, cancel",
      textConfirm: `Yes, delete this ${props.name}`,
      textLoading: "Deleting ...",
      icon: "mdi-trash-can-outline",
      color: "red",
      customClass: "w-[400px]",
      showClose: false,
      async confirm() {
        emit('trash-delete-permanently', trashesItem.id)
        closePopUp();
        showToast(`${trashesItem.title || trashesItem.item || trashesItem.contact_name} ${props.name} deleted successfully`, 'error');
      },
    });
  } catch (error) {
    console.log(error);
  }
};

defineExpose({
  isActive
})
</script>
