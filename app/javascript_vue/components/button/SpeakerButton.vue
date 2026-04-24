<template>
  <v-btn
    color="primary"
    @click="test"
    :disabled="!isSupported"
    class="px-4 py-2 rounded-full flex items-center"
  >
    <v-icon :icon="isPlaying ? 'mdi-volume-high' : 'mdi-volume-off'" class="mr-2" />
    {{ isPlaying ? 'Speaking...' : 'Speak' }}
  </v-btn>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue';
import { useSpeechSynthesis } from '@vueuse/core';

const props = defineProps({
  text: {
    type: String,
    required: true,
  },
});

const selectedVoice = ref(null);

const {
  isSupported,
  isPlaying,
  status,
  utterance,
  error,
  toggle,
  speak,
} = useSpeechSynthesis(props.text, {
  lang: 'en-US',
  pitch: 1,
  rate: 1,
  volume: 1,
});

const voices = ref([]);

onMounted(() => {
  updateVoices();
  window.speechSynthesis.onvoiceschanged = updateVoices;
});

const updateVoices = () => {
  voices.value = window.speechSynthesis.getVoices();
  const englishVoice = voices.value.find(voice => voice.lang.startsWith('en-'));
  if (englishVoice) {
    selectedVoice.value = englishVoice;
    utterance.value.voice = englishVoice;
  }
};

watch(selectedVoice, (newVoice) => {
  if (newVoice) {
    utterance.value.voice = newVoice;
  }
});

watch(() => props.text, (newText) => {
  utterance.value.text = newText;
});

const test = () => {
  stop()
  speak()
}
</script>