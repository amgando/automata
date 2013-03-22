# mail weekly feedback


usage:

```  
$ ruby mail_feedback.rb   
```


sample output:

    opening session with google...
    grabbing a reference to the retro worksheet... done.

    generating new entries from 193 rows. done.
    generating reports as markdown...
    	filtered total down to 12 records. done.
    	filtered total down to 16 records. done.
    	filtered total down to 22 records. done.

    generating PDFs from 3 markdown file(s).
    	this can take a while depending on how many reports are going out. done.

    mailing out reports
    	sending sea_lions_3_22 to ["jesse", "shadi"]. sent.
    	sending banana_slugs_3_22 to ["jeffrey", "anne"]. sent.
    	sending golden_bears_3_22 to ["brick", "zee"]. sent.

    cleaning up temp files...all clean.

    all done. check your inbox  


