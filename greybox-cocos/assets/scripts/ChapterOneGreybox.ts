import { _decorator, Button, Color, Component, Graphics, Label, Node, UITransform, Vec3 } from 'cc';
import {
  CHAPTERS,
  createInitialGreyboxState,
  getAvailableInteractions,
  getCurrentScene,
  performInteraction,
} from './greyboxState.js';

const { ccclass, property } = _decorator;

type GreyboxState = ReturnType<typeof createInitialGreyboxState>;
type SceneData = NonNullable<ReturnType<typeof getCurrentScene>>;

type RectData = {
  x: number;
  y: number;
  width: number;
  height: number;
};

type HotspotData = RectData & {
  action: string;
  tone?: string;
};

type InteractionData = {
  id: string;
  label: string;
  hotspot?: HotspotData;
};

@ccclass('ChapterOneGreybox')
export class ChapterOneGreybox extends Component {
  @property(Label)
  public sceneTitle: Label | null = null;

  @property(Label)
  public sceneCopy: Label | null = null;

  @property(Label)
  public feedback: Label | null = null;

  @property(Label)
  public chapterStatus: Label | null = null;

  @property(Node)
  public interactionRoot: Node | null = null;

  private goalLabel: Label | null = null;
  private stageRoot: Node | null = null;
  private progressHint: Label | null = null;
  private state: GreyboxState = createInitialGreyboxState();

  start() {
    this.ensureRuntimeUi();
    this.render('点击高亮热点，开始第一章灰盒验证。');
  }

  public resetPrototype() {
    this.state = createInitialGreyboxState();
    this.render('已重置第一章灰盒。');
  }

  public runInteraction(_event: unknown, interactionId: string) {
    this.state = performInteraction(this.state, interactionId);
    this.render(this.state.lastFeedback);
  }

  private render(message: string) {
    const scene = getCurrentScene(this.state);
    if (!scene) {
      return;
    }

    if (this.sceneTitle) {
      this.sceneTitle.string = scene.title;
    }
    if (this.sceneCopy) {
      this.sceneCopy.string = scene.copy;
    }
    if (this.goalLabel) {
      this.goalLabel.string = `目标：${scene.goal}`;
    }
    if (this.feedback) {
      this.feedback.string = `反馈：${message}`;
    }
    if (this.progressHint) {
      this.progressHint.string = this.buildProgressHint();
    }
    if (this.chapterStatus) {
      const chapterLines = CHAPTERS.map((chapter) => `${chapter.title} · ${chapter.status}`);
      this.chapterStatus.string = [`进度：${this.state.chapterProgress}`, ...chapterLines].join('\n');
    }

    this.renderSceneStage(scene);
    this.syncInteractionButtons();
  }

  private renderSceneStage(scene: SceneData) {
    if (!this.stageRoot) {
      return;
    }

    this.stageRoot.removeAllChildren();
    this.createPanel(this.stageRoot, 'StageBackdrop', new Vec3(0, 0, 0), 840, 330, new Color(16, 18, 17, 255), new Color(94, 103, 92, 255), 3);
    this.createLabelOn(this.stageRoot, 'StageCaption', scene.stage.caption, new Vec3(0, 144, 0), 14, new Color(165, 176, 161, 255), 790, 24);

    scene.stage.elements.forEach((element: RectData & { label: string; color?: number[] }) => {
      const fill = this.colorFrom(element.color, [66, 70, 66, 230]);
      const elementNode = this.createPanel(this.stageRoot, `StageElement:${element.label}`, new Vec3(element.x, element.y, 0), element.width, element.height, fill, new Color(112, 121, 106, 230), 2);
      this.createLabelOn(elementNode, 'ElementLabel', element.label, new Vec3(0, 0, 0), 13, new Color(221, 226, 210, 255), element.width - 8, Math.min(element.height, 44));
    });
  }

  private syncInteractionButtons() {
    if (!this.interactionRoot) {
      return;
    }

    this.interactionRoot.removeAllChildren();
    getAvailableInteractions(this.state).forEach((interaction: InteractionData, index: number) => {
      this.createHotspotButton(interaction, index);
    });
  }

  private createHotspotButton(interaction: InteractionData, index: number) {
    if (!this.interactionRoot) {
      return;
    }

    const hotspot = interaction.hotspot ?? this.fallbackHotspot(index);
    const buttonNode = this.createPanel(
      this.interactionRoot,
      `Hotspot:${interaction.id}`,
      new Vec3(hotspot.x, hotspot.y, 0),
      hotspot.width,
      hotspot.height,
      this.hotspotFill(hotspot.tone),
      this.hotspotStroke(hotspot.tone),
      3,
    );
    const button = buttonNode.addComponent(Button);
    const eventHandler = new Component.EventHandler();
    eventHandler.target = this.node;
    eventHandler.component = 'ChapterOneGreybox';
    eventHandler.handler = 'runInteraction';
    eventHandler.customEventData = interaction.id;
    button.clickEvents.push(eventHandler);

    this.createLabelOn(buttonNode, 'HotspotLabel', `${index + 1}. ${hotspot.action}\n${interaction.label}`, new Vec3(0, 0, 0), 14, new Color(255, 248, 216, 255), hotspot.width - 10, hotspot.height - 8);
  }

  private ensureRuntimeUi() {
    if (!this.sceneTitle) {
      this.sceneTitle = this.createLabel('SceneTitle', new Vec3(0, 286, 0), 28, new Color(235, 238, 226, 255), 760, 40);
    }
    if (!this.sceneCopy) {
      this.sceneCopy = this.createLabel('SceneCopy', new Vec3(0, 246, 0), 17, new Color(198, 205, 196, 255), 760, 34);
    }
    if (!this.goalLabel) {
      this.goalLabel = this.createLabel('Goal', new Vec3(0, 214, 0), 16, new Color(255, 232, 162, 255), 760, 34);
    }
    if (!this.stageRoot) {
      this.stageRoot = new Node('GreyboxStage');
      this.node.addChild(this.stageRoot);
      this.stageRoot.setPosition(new Vec3(0, 8, 0));
      this.stageRoot.addComponent(UITransform).setContentSize(840, 330);
    }
    if (!this.interactionRoot) {
      this.interactionRoot = new Node('InteractionHotspots');
      this.node.addChild(this.interactionRoot);
    }
    this.interactionRoot.setPosition(new Vec3(0, 8, 0));

    if (!this.feedback) {
      this.feedback = this.createLabel('Feedback', new Vec3(0, -184, 0), 18, new Color(237, 241, 223, 255), 760, 38);
    }
    if (!this.progressHint) {
      this.progressHint = this.createLabel('ProgressHint', new Vec3(0, -225, 0), 14, new Color(158, 177, 171, 255), 760, 36);
    }
    if (!this.chapterStatus) {
      this.chapterStatus = this.createLabel('ChapterStatus', new Vec3(246, -278, 0), 11, new Color(119, 134, 130, 255), 300, 76);
    }
  }

  private buildProgressHint(): string {
    const roomCount = this.state.chapterOne.roomObjectsRead.length;
    const marks = Object.values(this.state.chapterOne.vehicleMarks).filter((mark) => mark === 'friend' || mark === 'enemy').length;
    const signal = this.state.chapterOne.signalRhythm.join('、') || '未开始';
    return `下一步提示：房间 ${roomCount}/3 · 车窗 ${this.state.chapterOne.windowObservationCount}/3 · 车阵 ${marks}/5 · 信号 ${signal} · 回声 ${this.state.echoObjectsVisited.length}/3`;
  }

  private fallbackHotspot(index: number): HotspotData {
    const column = index % 3;
    const row = Math.floor(index / 3);
    return {
      x: -250 + column * 250,
      y: 78 - row * 76,
      width: 160,
      height: 54,
      action: '点击',
      tone: 'default',
    };
  }

  private createPanel(parent: Node, name: string, position: Vec3, width: number, height: number, fill: Color, stroke: Color, lineWidth = 2): Node {
    const node = new Node(name);
    parent.addChild(node);
    node.setPosition(position);
    node.addComponent(UITransform).setContentSize(width, height);

    const graphics = node.addComponent(Graphics);
    graphics.lineWidth = lineWidth;
    graphics.fillColor = fill;
    graphics.strokeColor = stroke;
    graphics.rect(-width / 2, -height / 2, width, height);
    graphics.fill();
    graphics.stroke();
    return node;
  }

  private createLabel(name: string, position: Vec3, fontSize: number, color: Color, width: number, height: number): Label {
    const node = new Node(name);
    this.node.addChild(node);
    node.setPosition(position);
    node.addComponent(UITransform).setContentSize(width, height);
    const label = node.addComponent(Label);
    this.styleLabel(label, '', fontSize, color);
    return label;
  }

  private createLabelOn(parent: Node, name: string, text: string, position: Vec3, fontSize: number, color: Color, width: number, height: number): Label {
    const node = new Node(name);
    parent.addChild(node);
    node.setPosition(position);
    node.addComponent(UITransform).setContentSize(width, height);
    const label = node.addComponent(Label);
    this.styleLabel(label, text, fontSize, color);
    return label;
  }

  private styleLabel(label: Label, text: string, fontSize: number, color: Color) {
    label.string = text;
    label.fontSize = fontSize;
    label.lineHeight = fontSize + 5;
    label.color = color;
    label.horizontalAlign = Label.HorizontalAlign.LEFT;
    label.verticalAlign = Label.VerticalAlign.TOP;
  }

  private colorFrom(value: number[] | undefined, fallback: number[]): Color {
    const color = value ?? fallback;
    return new Color(color[0], color[1], color[2], color[3] ?? 255);
  }

  private hotspotFill(tone: string | undefined): Color {
    const palette: Record<string, number[]> = {
      reality: [83, 84, 69, 220],
      entry: [67, 94, 110, 225],
      friend: [58, 104, 70, 225],
      enemy: [112, 62, 67, 225],
      route: [96, 91, 58, 225],
      collect: [130, 104, 55, 225],
      green: [50, 122, 77, 230],
      red: [132, 55, 57, 230],
      echo: [64, 94, 97, 225],
      exit: [93, 83, 63, 225],
      default: [76, 81, 74, 220],
    };
    return this.colorFrom(palette[tone ?? 'default'], palette.default);
  }

  private hotspotStroke(tone: string | undefined): Color {
    const palette: Record<string, number[]> = {
      reality: [212, 194, 128, 255],
      entry: [147, 201, 224, 255],
      friend: [152, 220, 151, 255],
      enemy: [235, 141, 138, 255],
      route: [231, 211, 122, 255],
      collect: [242, 204, 113, 255],
      green: [146, 238, 166, 255],
      red: [250, 142, 138, 255],
      echo: [139, 214, 211, 255],
      exit: [236, 216, 132, 255],
      default: [210, 218, 196, 255],
    };
    return this.colorFrom(palette[tone ?? 'default'], palette.default);
  }
}
