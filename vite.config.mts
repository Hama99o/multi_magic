import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';
import RubyPlugin from 'vite-plugin-ruby';
import { resolve } from 'path';

export default defineConfig({
  plugins: [tailwindcss(), react(), RubyPlugin()],
  resolve: {
    extensions: ['.mjs', '.js', '.ts', '.jsx', '.tsx', '.json'],
    alias: { '@': resolve(__dirname, 'app/javascript') },
  },
  server: {
    allowedHosts: true,
    hmr: {
      overlay: true,
    },
    watch: {
      usePolling: true,
      interval: 500,
    },
  },
});
