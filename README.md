# capacitor-plugin-video

Background/fullscreen video player for onboarding

## Install

```bash
npm install capacitor-plugin-video
npx cap sync
```

## API

<docgen-index>

* [`play(...)`](#play)
* [`stop()`](#stop)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### play(...)

```typescript
play(options: PlayOptions) => any
```

| Param         | Type                                                |
| ------------- | --------------------------------------------------- |
| **`options`** | <code><a href="#playoptions">PlayOptions</a></code> |

**Returns:** <code>any</code>

--------------------


### stop()

```typescript
stop() => any
```

**Returns:** <code>any</code>

--------------------


### Interfaces


#### PlayOptions

| Prop        | Type                 |
| ----------- | -------------------- |
| **`src`**   | <code>string</code>  |
| **`muted`** | <code>boolean</code> |
| **`loop`**  | <code>boolean</code> |

</docgen-api>
