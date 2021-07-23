import ConfigOptions from "./config";

type ValueOf<T> = T[keyof T];

export type ButtonsOptions = ValueOf<ConfigOptions.Buttons>;
export type ToolsOptions = ValueOf<ConfigOptions.Tools>;
export type FitModeOptions = ValueOf<ConfigOptions.FitMode>;
export type LayoutModeOptions = ValueOf<ConfigOptions.LayoutMode>;
export type FieldFlagsOptions = ValueOf<ConfigOptions.FieldFlags>;
export type AnnotationMenuOptions = ValueOf<ConfigOptions.AnnotationMenu>;
export type EraserTypeOptions = ValueOf<ConfigOptions.EraserType>;
export type LongPressMenuOptions = ValueOf<ConfigOptions.LongPressMenu>;
export type ActionsOptions = ValueOf<ConfigOptions.Actions>;
export type AnnotationFlagsOptions = ValueOf<ConfigOptions.AnnotationFlags>;
export type DefaultToolbarsOptions = ValueOf<ConfigOptions.DefaultToolbars>;
export type ToolbarIconsOptions = ValueOf<ConfigOptions.ToolbarIcons>;
export type CustomToolbarKeyOptions = ValueOf<ConfigOptions.CustomToolbarKey>;
export type ThumbnailFilterModeOptions = ValueOf<ConfigOptions.ThumbnailFilterMode>;
export type ConversionOptions = ValueOf<ConfigOptions.Conversion>;
export type ViewModePickerItemOptions = ValueOf<ConfigOptions.ViewModePickerItem>;
export type ZoomLimitModeOptions = ValueOf<ConfigOptions.ZoomLimitMode>;
export type OverprintModeOptions = ValueOf<ConfigOptions.OverprintMode>;
export type ColorPostProcessModeOptions = ValueOf<ConfigOptions.ColorPostProcessMode>;
export type ReflowOrientationOptions = ValueOf<ConfigOptions.ReflowOrientation>;
export type ExportFormatOptions = ValueOf<ConfigOptions.ExportFormat>;