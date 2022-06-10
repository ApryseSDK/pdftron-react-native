# Wonday Compatibility API

### DocumentView - Props

#### source
string

The path or url to the document.
Same as `document`.

Example:

```js
<DocumentView
  source={'https://pdftron.s3.amazonaws.com/downloads/pl/PDFTRON_about.pdf'}
/>
```

#### scale
double, optional

This prop defines the zoom of the document.
Same as `zoom`.

```js
<DocumentView
  scale={2.0}
/>
```

#### fitPolicy

Defines the fit mode (default zoom level) of the viewer.
Equivalent to `fitMode`.

Parameters:

| Mode              | Value | Description            |
|-------------------|-------|------------------------|
| fitPage (default) | 0     | fits the whole page    |
| fit width         | 1     | fits page using width  |
| fit hieght        | 2     | fits page using height |

```js
<DocumentView
  fitPolicy={2}
/>
```

#### page
number, optional

Defines the initial page number that viewer displays when the document is opened. Note that page numbers are 1-indexed.
Same as `initialPageNumber`.

```js
<DocumentView
  page={5}
/>
```

#### onLoadComplete
function, optional

This function is called when the document finishes loading.
Same as `onDocumentLoaded`.

Parameters:

| Name | Type   | Description                                   |
|------|--------|-----------------------------------------------|
| path | string | File path that the document has been saved to |

```js
<DocumentView
  onLoadComplete = {(path) => { 
    console.log('The document has finished loading:', path); 
  }}
/>
```

#### onScaleChanged
function, optional

This function is called when the zoom scale has been changed.
Same as `onZoomChanged`.

Parameters:

| Name | Type   | Description                            |
|------|--------|----------------------------------------|
| zoom | double | the current zoom ratio of the document |

```js
<DocumentView
  onScaleChanged = {(scale) => {
    console.log('Current scale ratio is', scale);
  }}
/>
```

#### onError
function, optional

This function is called when document opening encounters an error.
Same as `onDocumentError`.

Parameters:

| Name  | Type   | Description            |
|-------|--------|------------------------|
| error | string | Error message produced |

```js
<DocumentView
  onError = {(error) => { 
    console.log('Error occured during document opening:', error); 
  }}
/>
```
