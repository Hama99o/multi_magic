import { VueNodeViewRenderer } from '@tiptap/vue-3';
import { mergeAttributes } from '@tiptap/core';
import { Image } from '@tiptap/extension-image'

import ImageBlockView from '../components/image/ImageBlockView.vue';

export const ImageBlock = Image.extend({
  name: 'imageBlock',
  group: 'block',
  defining: true,
  isolating: true,

  addOptions() {
    return {
      inline: false,
      allowBase64: true,
      HTMLAttributes: {},
    }
  },

  addAttributes() {
    return {
      src: {
        default: '',
        parseHTML: element => element.getAttribute('src'),
        renderHTML: attributes => ({
          src: attributes.src,
        }),
      },
      width: {
        default: '50%',
        parseHTML: element => element.getAttribute('data-width'),
        renderHTML: attributes => ({
          'data-width': attributes.width,
        }),
      },
      align: {
        default: 'center',
        parseHTML: element => element.getAttribute('data-align'),
        renderHTML: attributes => ({
          'data-align': attributes.align,
        }),
      },
      alt: {
        default: undefined,
        parseHTML: element => element.getAttribute('alt'),
        renderHTML: attributes => ({
          alt: attributes.alt,
        }),
      },
    };
  },

  parseHTML() {
    return [
      {
        tag: this.options.allowBase64
          ? 'img[src]'
          : 'img[src]:not([src^="data:"])',
      },
    ]
  },

  renderHTML({ HTMLAttributes }) {
    return ['img', mergeAttributes(this.options.HTMLAttributes, HTMLAttributes)];
  },

  addCommands() {
    return {
      setImage: options => ({ commands }) => {
        return commands.insertContent({
          type: this.name,
          attrs: options,
        })
      },
      setImageBlock: (attrs) => ({ commands }) => {
        return commands.insertContent({ type: 'imageBlock', attrs: { src: attrs.src } });
      },

      setImageBlockAt: (attrs) => ({ commands }) => {
        return commands.insertContentAt(attrs.pos, { type: 'imageBlock', attrs: { src: attrs } });
      },

      setImageBlockAlt: (attrs) => ({ commands }) => {
        return commands.updateAttributes('imageBlock', { alt: attrs.alt });
      },


      setImageBlockAlign: (align) => ({ commands }) => {
        return commands.updateAttributes('imageBlock', { align });
      },

      setImageBlockWidth: (width) => ({ commands }) => {
        return commands.updateAttributes('imageBlock', { width: `${Math.max(0, Math.min(100, width))}%` });
      },
    };
  },

  addNodeView() {
    return VueNodeViewRenderer(ImageBlockView);
  },
});

export default ImageBlock;