export interface ResultData<T> {
  success: boolean;

  message: string;

  data: T;
}
