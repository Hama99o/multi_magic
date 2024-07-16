
import {createApp} from "vue";
import App from '@/App.vue';
import {registerPlugins} from "@/plugins/index.js";
// import '@/assets/css/multi_magic.scss';

const app = createApp(App);

// plugins
registerPlugins(app)
app.mount("#app");