class NoteApp::NoteChannel < ApplicationCable::Channel
  def subscribed
    @note = NoteApp::Note.find_by(id: params[:note_id])
    return reject_subscription if @piece.nil?

    stream_for @note
  end

  def update(args)
    note = NoteApp::Note.find_by(id: params[:note_id])
    if note.nil?
      return connection.transmit(
        identifier: params,
        error: "note not found"
      )
    end
    if note.update(args.slice("title", "description"))
      NoteApp::NoteChannel.broadcast_to(
        note,
        {
          status: :update,
          entity: NoteApp::NoteSerializer.render_as_hash(note)
        }
      )
    else
      connection.transmit identifier: params,
                          error: note.errors.full_messages
    end
  end
end
