# automata

this is a list of small projects that have been automated to save time in lots of small chunks that add up to something useful.

the list of projects includes:

### mail weekly feedback

every week we collect student feedback.  this utility grabs that feedback from google drive using [google_drive](https://github.com/gimite/google-drive-ruby) and sends it out to phase teachers as PDF attachments using [mail](https://github.com/mikel/mail)

> TODO
- oauth implementation
- dynamic teacher+cohort association form central repo somewhere
- deployment to automated host so it's off my laptop
- dashboard and kpis so we only have to think about it if it's broken

---

### report weekly feedback

same as \[mail weekly feedback\] but this tool generates reports using [mattetti-googlecharts](https://github.com/mattetti/googlecharts)

> TODO
- embed the charts with \[mail weekly feedback\] PDFs
- embed the charts into [dashing](http://shopify.github.com/dashing/)
- add interactivity to the charts
