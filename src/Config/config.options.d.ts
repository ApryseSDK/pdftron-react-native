import ConfigOptions from "./config";

type ValueOf<T> = T[keyof T];

export type AnnotationFlagsOptions = ValueOf<ConfigOptions.AnnotationFlags>;