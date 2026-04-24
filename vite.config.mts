import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import RubyPlugin from 'vite-plugin-ruby';

export default defineConfig({
  resolve: {
    extensions: ['.mjs', '.js', '.ts', '.jsx', '.tsx', '.json', '.vue'],
    dedupe: ['vuetify'],
  },
  plugins: [vue(), RubyPlugin()],
  css: {
    preprocessorOptions: {
      scss: {
        sourceMap: false,
      },
    },
  },
});