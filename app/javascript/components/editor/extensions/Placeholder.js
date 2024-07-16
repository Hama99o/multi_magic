import PlaceholderTiptap from '@tiptap/extension-placeholder';

export const Placeholder = PlaceholderTiptap.configure({
  includeChildren: true,
  showOnlyCurrent: true,
  placeholder: "Type / to browse options",
  considerAnyAsEmpty: true,
})

export default Placeholder