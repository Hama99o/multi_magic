<template>
  <v-dialog v-model="dialog" max-width="600px">
    <div class="bg-surface p-4">
      <div v-bind="getRootProps()" class="rounded-lg">
        <!-- Input for drag-and-drop file upload -->
        <input v-bind="getInputProps()" />
        <div
          :class="[
            isDragActive ? 'bg-gray-100' : '',
          ]"
          class="rounded-lg border border-dashed border-gray-300 px-8 py-12 mb-4"
        >
          <p
            v-if="isDragActive"
            class="text-center text-sm font-medium text-gray-700"
          >
            Drop the files here ...
          </p>
          <p v-else class="text-center text-sm font-medium text-gray-700">
            Drag 'n' drop some image file here, or click to select file
          </p>
        </div>
      </div>

      <!-- Input for image URL -->
      <div class="pt-2">
        <v-text-field
          v-model="imageUrl"
          label="Or enter image URL"
          placeholder="https://example.com/image.png"
          outlined
          dense
          class="w-full"
        />
        <!-- Action buttons -->
        <div class="flex justify-end space-x-2">
          <v-btn @click="closeDialog" color="grey" class="mr-2">Cancel</v-btn>
          <v-btn @click="insertImageFromUrl" color="primary">Insert Image</v-btn>
        </div>
      </div>
    </div>
  </v-dialog>
</template>


<script setup lang="ts">
import { onMounted, ref } from "vue"
import { useDropzone } from "vue3-dropzone"
import axios from "axios"
import type ImageData from "@/models/image"
import ImageAPI from '@/apis/image.api';
import { showToast } from '@/utils/showToast';

const props = defineProps({
  recordId: {
    type: Object,
    required: true,
  },
});

const emit = defineEmits<{
  (e: "close"): void
  (e: "insert", url: string): void
}>()
const dialog = ref(false)
const imageUrl = ref("") // Input field for image URL
const { getRootProps, getInputProps, isDragActive } = useDropzone({
  accept: "image/png,image/jpeg, image/jpg, image/gif, image/webp",
  multiple: false,
  onDrop: onDropImage,
  noClick: false,
})

function closeDialog() {
  emit("close")
  imageUrl.value = ''
}

async function onDropImage(acceptedFiles: any[]) {
  try {
    const formData = new FormData()
    formData.append("file", acceptedFiles[0])
    formData.append("note_id", props.recordId)

    const imageUrl = await ImageAPI.createImage(formData)
    emit("insert", imageUrl)
    closeDialog()
  } catch (error) {
    console.error("Error uploading image from URL", error)
    showToast('Error uploading image from URL', 'error');
  }

}

// Main function to determine if the URL is a GIF or an image, fetch accordingly, and upload
async function insertImageFromUrl() {
  if (!imageUrl.value.trim()) return;

  try {
    let file;

    // Check if the URL ends in .gif to decide the fetch method
    if (imageUrl.value.toLowerCase().endsWith(".gif")) {
      file = await fetchGifFromUrl(imageUrl.value);
    } else {
      file = await fetchFileFromUrl(imageUrl.value);
    }

    if (file) {
      console.log(file)
      // Create a FormData object with the fetched file
      const formData = new FormData()
      formData.append("file", file)
      formData.append("note_id", props.recordId)

      // Upload to the backend
      const uploadedImageUrl = await ImageAPI.createImage(formData)

      // Emit the uploaded image URL for insertion
      emit("insert", uploadedImageUrl)
      closeDialog()
    }
  } catch (error) {
    console.error("Error uploading image from URL", error);
    showToast("Error uploading image from URL", "error");
  }
}

// Function to specifically fetch GIFs from a URL
async function fetchGifFromUrl(url: string): Promise<File | null> {
  try {
    const response = await fetch(url);
    const blob = await response.blob();

    if (!response.ok) throw new Error("Failed to fetch GIF");

    // Ensure it’s a GIF type
    if (!['image/gif', 'image/webp'].includes(blob.type)) {
      throw new Error("File is not a GIF");
    }

    // Extract filename from the URL or use a default one
    const fileName = url.split("/").pop() || `tmp-${new Date().getTime()}.gif`;
    return new File([blob], fileName, { type: blob.type });
  } catch (error) {
    console.error("Failed to fetch GIF from URL:", error);
    showToast("Failed to fetch GIF from URL", "error");
    return null;
  }
}

// Function to fetch image from URL and convert to a File object
async function fetchFileFromUrl(url: string): Promise<File | null> {
  try {
    const response = await fetch(url)
    const blob = await response.blob()

    if (!response.ok) throw new Error("Failed to fetch image")

    // Extract filename from the URL or set a default one
    const fileName = url.split("/").pop() || `tmp-${new Date().getTime()}.png`
    return new File([blob], fileName, { type: blob.type })
  } catch (error) {
    console.error("Failed to fetch image from URL:", error)
    showToast('Failed to fetch image from URL', 'error');
    return null
  }
}

defineExpose({
  dialog
})

</script>
