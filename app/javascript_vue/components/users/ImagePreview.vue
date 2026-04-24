<template>
  <!-- Avatar Preview Dialog -->
  <v-dialog v-model="dialog" max-width="600px">
    <v-card class="rounded-lg overflow-hidden bg-surface">
      <v-card-text class="p-0 relative">
        <!-- The image preview -->
        <v-img
          :src="image"
          alt="User Avatar"
          class="w-full h-auto"
          contain
          gradient="to bottom, rgba(0,0,0,.1), rgba(0,0,0,.5)"
        >
          <!-- Close button -->
          <v-btn
            icon
            large
            class="absolute top-0 right-0 m-4"
            @click="dialog = false"
          >
            <v-icon class="text-primary">mdi-close</v-icon>
          </v-btn>

          <!-- Action buttons at the bottom of the image -->
          <div class="absolute bottom-0 left-0 w-full p-4 flex justify-between items-center">
            <v-btn
              icon
              v-if="isCurrentUser"
              large
              class="hover:bg-red-200"
              @click="deleteAvatar"
            >
              <v-icon class="text-primary">mdi-delete</v-icon>
            </v-btn>

            <v-btn
              icon
              large
              v-if="isCurrentUser"
              @click="triggerFileInput"
            >
              <v-icon class="text-primary">mdi-image-edit</v-icon>
            </v-btn>
          </div>
        </v-img>
      </v-card-text>
    </v-card>
  </v-dialog>
</template>

<script setup>
import { ref } from 'vue';

const props = defineProps({
  image: { type: String, default: null },
  imageType: { type: String, default: 'photo' },
  isCurrentUser: { type: Boolean, default: false },
});

const emits = defineEmits(['open-edit-image-dialog', 'delete-photo'])

const dialog = ref(false);
const deleteAvatar = () => {
  emits('delete-avatar')
  dialog.value = false;
};

const triggerFileInput = () => {
  emits('open-edit-image-dialog')
  dialog.value = false;
};

defineExpose({
  dialog
})
</script>
