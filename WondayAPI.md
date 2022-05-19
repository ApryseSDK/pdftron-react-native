# Wonday Compatibility API

### DocumentView - Props

#### source
string

The path or url to the document.

Example:

```js
<DocumentView
  source={'https://pdftron.s3.amazonaws.com/downloads/pl/PDFTRON_about.pdf'}
/>
```

#### scale
double, optional

This prop defines the zoom of the document.
Same as zoom.

```js
<DocumentView
  scale={2.0}
/>
```

#### onError
function, optional

This function is called when document opening encounters an error.

Parameters:

Name | Type | Description
--- | --- | ---
error | string | Error message produced

```js
<DocumentView
  onError = {(error) => { 
    console.log('Error occured during document opening:', error); 
  }}
/>
```
