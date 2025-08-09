export interface VideoPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
