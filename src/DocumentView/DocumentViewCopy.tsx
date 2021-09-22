import React, { PureComponent } from 'react';
import PropTypes, { array, Requireable, Validator } from 'prop-types';
import {
  requireNativeComponent,
  ViewPropTypes,
  Platform,
  NativeModules,
  findNodeHandle,
} from 'react-native';
const { DocumentViewManager } = NativeModules;
import {Config} from "../Config/Config";
import * as AnnotOptions from "../AnnotOptions/AnnotOptions";

/** 
 * Object containing PropTypes types for {@link DocumentView} class.
 * Also used to generate prop types for TS users.
 * 
 * To represent functions, please use {@link func}.
 * To represent "one of Config.Buttons values" or "an array of 
 * Config.Buttons values", please use {@link oneOf} or {@link arrayOf}.
 */
const propTypes = {
  document: PropTypes.string.isRequired,
  password: PropTypes.string,
  initialPageNumber: PropTypes.number,

  // Any Config.FitMode constant.
  fitMode: oneOf<Config.FitMode>(Config.FitMode),

  // Array of Config.Tools constants.
  disabledTools: arrayOf<Config.Tools>(Config.Tools),

  // A function with parameter "path" of type string.
  onDocumentLoaded: func< (path: string) => void >(),

  ...ViewPropTypes,
};

// Generates the prop types for TypeScript users, from PropTypes.
type DocumentViewProps = PropTypes.InferProps<typeof propTypes>;

/**
* Creates a custom PropType for functions.
*
* If the resulting PropType is used to generate prop types for TS users, 
* type checking for function parameters and return values will be provided.
* @returns {Requireable<T>} A custom PropType constant.
* @example
* func<(path: string) => void>()
*/
function func<T> () : Requireable<T> {
  
  let validator : Validator<T> = function (props: { [key: string]: any }, propName: string, componentName: string, location: string, propFullName: string) : Error | null {
    if (typeof props[propName] !== "function" && typeof props[propName] !== "undefined") {
      return new Error (`Invalid prop \`${propName}\` of type \`${typeof props[propName]}\` supplied to \`${componentName}\`, expected a function.`);
    }
    return null;
  }
  
  const t : Requireable<T> = validator as Requireable<T>;
  t.isRequired = validator as Validator<NonNullable<T>>;
  return t;
}

/** 
 * Creates a custom PropType representing any value from given object(s).
 * @param {object} obj An object containing values.
 * @param {...object} rest Indefinite number of other objects containing values.
 * @returns {Requireable<T>} A custom PropType constant.
 * @example
 * oneOf<Config.Tools>(Config.Tools)
 * oneOf<Config.Tools | Config.Buttons>(Config.Tools, Config.Buttons)
*/
function oneOf<T>(obj: object, ...rest: object[]) : Requireable<T> {
  if (rest.length > 0) {
    return PropTypes.oneOf(Object.values(Object.assign({}, obj, ...rest)));
  }
  return PropTypes.oneOf(Object.values(obj));
}

/** 
 * Creates a custom PropType representing any array containing values from given object(s).
 * @param {object} obj An object containing values.
 * @param {...object} rest Indefinite number of other objects containing values.
 * @returns {Requireable<T[]>} A custom PropType constant.
 * @example
 * arrayOf<Config.Tools>(Config.Tools)
 * arrayOf<Config.Tools | Config.Buttons>(Config.Tools, Config.Buttons)
*/
function arrayOf<T>(obj: object, ...rest: object[]) : Requireable<T[]> {
  return PropTypes.arrayOf(oneOf<T>(obj, ...rest)) as Requireable<T[]>;
}






export class DocumentView extends PureComponent<DocumentViewProps, any> {

  _viewerRef: any;

  static propTypes = propTypes;

  onChange = (event: any) => {
    // other event listeners
    if (event.nativeEvent.onDocumentLoaded) {
      if (this.props.onDocumentLoaded) {
        this.props.onDocumentLoaded(event.nativeEvent.onDocumentLoaded);
      }
    } 
  }

  // Methods
  
  /**
   * Selects the text within the given rectangle region.
   * @param rect the rectangle region in the format of x1: number, y1: number, x2: number, y2: number
   * @returns bool; whether there is text selected
   */
  selectInRect = (rect: AnnotOptions.Rect) : Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.selectInRect(tag, rect);
    }
    return Promise.resolve();
  }

  _setNativeRef = (ref: any) => {
    this._viewerRef = ref;
  };

  render() {
    return (
      // @ts-ignore
      <RCTDocumentView
        ref={this._setNativeRef}
        style={{ flex:1 }}
        // @ts-ignore: Intentionally exclude `onChange` from being exposed as a prop.
        onChange={this.onChange}
        {...this.props}
      />
    )
  }
}

const name = Platform.OS === 'ios' ? 'RNTPTDocumentView' : 'RCTDocumentView';

const RCTDocumentView = requireNativeComponent(name);







