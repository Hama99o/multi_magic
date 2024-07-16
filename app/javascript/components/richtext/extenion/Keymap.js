import { Extension } from '@tiptap/core';

// Define and create the Keymap extension
const Keymap = Extension.create({
  name: 'Keymap',

  // Define custom commands for the extension
  addCommands() {
    return {
      handleEnterKey:
        () =>
        ({ state, chain, editor }) => {
          const { selection, doc } = state;
          const { $from, $to } = selection;

          if (editor.extensionManager.extensions?.find((e) => e.name === 'draggableItem')) {
            if ($from.parent.type.name === 'codeBlock') return false;

            // Check if the cursor is within a draggableItem, no selection is made, and if it's at the end of a block.
            if (
              ($from.node(-1).type.name === 'draggableItem' ||
                $from.node(-1).type.name === 'listItem' ||
                $from.node(-1).type.name !== 'taskItem' ||
                $from.node(-1).type.name === 'blockquote') &&
              $from.parent.type.isBlock &&
              $to.pos === $from.pos &&
              !document.getElementById('menuContainer')
            ) {
              if ($to.pos === $from.end()) {
                // Create and focus on a new root block with a paragraph inside at the cursor position
                return chain()
                  .insertContentAt($from.pos, {
                    type: 'draggableItem',
                    content: [
                      {
                        type: 'paragraph',
                      },
                    ],
                  })
                  .focus()
                  .run();
              } else {
                // console.log("Cursor is not at the end of the block");

                let currentActiveNodeTo = -1;

                // Iterate over document nodes to find the active node's end position.
                doc.descendants((node, pos) => {
                  if (currentActiveNodeTo !== -1) return false;
                  if (node.type.name === 'draggableItem') return;

                  const [nodeFrom, nodeTo] = [pos, pos + node.nodeSize];
                  if (nodeFrom <= $from.pos && $to.pos <= nodeTo) currentActiveNodeTo = nodeTo;

                  return false;
                });

                const content = doc.slice($from.pos, currentActiveNodeTo)?.toJSON().content;

                // Replace content from cursor to the end of the block with new content.
                return chain()
                  .insertContentAt(
                    { from: $from.pos, to: currentActiveNodeTo },
                    {
                      type: 'draggableItem',
                      content,
                    },
                  )
                  .focus()
                  .run();
              }
            }
          } else {
            if (
              $from.parent.type.name === 'paragraph' &&
              document.getElementById('menuContainer')
            ) {
              return true;
            }
          }

          // If conditions aren't met, use the default Enter behavior
          return false;
        },
    };
  },

  // Define keyboard shortcuts for the extension
  addKeyboardShortcuts() {
    return {
      Enter: ({ editor }) => editor.commands.handleEnterKey(), // Call handleEnterKey command on Enter key press
    };
  },
});

export default Keymap;
