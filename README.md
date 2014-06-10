# transcription-mode

The gist of the mode is to be able to precisely control media playback
while in a buffer containing that media's transcription. The main use
case is to rewind the video by a few second in order to re-listen to a
few words so they can be typed into the buffer, or corrected. It uses
VideoLAN's console interface to drive playback from within Emacs.

1. Open the transcription file.
2. Start the `transcription-mode` minor mode.
3. `M-x transcription-start` to select a media file to play.
4. Use the minor mode's keybindings to pause/play and seek.

Here's a non-exhaustive list of keybindings:

* <kbd>C-c C-c</kbd> Pause/play the media.
* <kbd>C-c s</kbd> Move backwards 3 seconds.
* <kbd>C-c S</kbd> Move forwards 3 seconds.
* <kbd>C-c t</kbd> Move backwards 10 seconds.
* <kbd>C-c T</kbd> Move forwards 10 seconds.
* <kbd>C-c m</kbd> Move backwards 1 minute.
* <kbd>C-c M</kbd> Move forwards 1 minute.

The media will still pop up in a VideoLAN window, so if you need to
make less common adjustments (playback speed, precise seeks, etc.) you
can switch focus and do it directly in VLC. The keybindings are for
frequent media control, like skipping back and forth by a few seconds.
