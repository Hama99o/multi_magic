export const GROUPS = [
  {
    title: 'Heading 1',
    command: ({ editor, range }) => {
      editor.chain().focus().deleteRange(range).setNode('heading', { level: 1 }).run();
    },
  },
  {
    title: 'Heading 2',
    command: ({ editor, range }) => {
      editor.chain().focus().deleteRange(range).setNode('heading', { level: 2 }).run();
    },
  },
  {
    title: 'Heading 3',
    command: ({ editor, range }) => {
      editor.chain().focus().deleteRange(range).setNode('heading', { level: 3 }).run();
    },
  },
  {
    title: 'Bulleted List',
    command: ({ editor, range }) => {
      editor.chain().focus().deleteRange(range).toggleBulletList().run();
    },
  },
  {
    title: 'Numbered List',
    command: ({ editor, range }) => {
      editor.chain().focus().deleteRange(range).toggleOrderedList().run();
    },
  },
  {
    title: 'Checklist',
    command: ({ editor, range }) => {
      editor.chain().focus().deleteRange(range).toggleTaskList().run();
    },
  },
  {
    title: 'Quote',
    command: ({ editor, range }) => {
      editor.chain().focus().deleteRange(range).setBlockquote().run();
    },
  },
  {
    title: 'Code Block',
    command: ({ editor, range }) => {
      editor.chain().focus().deleteRange(range).setCodeBlock().run();
    },
  },
  {
    title: 'Table',
    command: ({ editor, range }) => {
      // editor
      //   .chain()
      //   .focus()
      //   .deleteRange(range)
      //   .insertTable({ rows: 3, cols: 3, withHeaderRow: true })
      //   .run();
    },
  },
  {
    title: 'Image',
    command: ({ editor, range }) => {
      // editor.value?.chain().focus().setImageBlock({ src: 'url' }).run();
    },
  },
  {
    title: 'Youtube',
    command: ({ editor, range }) => {
      // const url = prompt('Enter YouTube URL');
      // editor.chain().focus().deleteRange(range).setYoutubeVideo({ src: url, width: '100%' }).run();
    },
  },
  {
    title: 'Divider',
    command: ({ editor, range }) => {
      editor.chain().focus().deleteRange(range).setHorizontalRule().run();
    },
  },
];

export default GROUPS;
