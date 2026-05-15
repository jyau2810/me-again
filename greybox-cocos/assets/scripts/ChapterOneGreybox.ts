import { _decorator, Button, Color, Component, Label, Node, UITransform, Vec3 } from 'cc';
import {
  CHAPTERS,
  createInitialGreyboxState,
  getAvailableInteractions,
  getCurrentScene,
  performInteraction,
} from './greyboxState.js';

const { ccclass, property } = _decorator;

type GreyboxState = ReturnType<typeof createInitialGreyboxState>;

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

  private state: GreyboxState = createInitialGreyboxState();

  start() {
    this.ensureRuntimeUi();
    this.render('点击现实物件，开始第一章灰盒验证。');
  }

  public resetPrototype() {
    this.state = createInitialGreyboxState();
    this.render('已重置第一章灰盒。');
  }

  public runInteraction(_event: Event, interactionId: string) {
    this.state = performInteraction(this.state, interactionId);
    this.render(this.state.lastFeedback);
  }

  private render(message: string) {
    const scene = getCurrentScene(this.state);
    if (this.sceneTitle && scene) {
      this.sceneTitle.string = scene.title;
    }
    if (this.sceneCopy && scene) {
      this.sceneCopy.string = scene.copy;
    }
    if (this.feedback) {
      this.feedback.string = message;
    }
    if (this.chapterStatus) {
      const chapterLines = CHAPTERS.map((chapter) => `${chapter.title} · ${chapter.status}`);
      this.chapterStatus.string = [
        `进度：${this.state.chapterProgress}`,
        `感知阶段：${this.state.perceptionStage}`,
        `当前章节：${this.state.currentChapter}`,
        ...chapterLines,
      ].join('\n');
    }

    this.syncInteractionButtons();
  }

  private syncInteractionButtons() {
    if (!this.interactionRoot) {
      return;
    }

    const interactions = getAvailableInteractions(this.state);
    this.interactionRoot.children.forEach((child, index) => {
      const interaction = interactions[index];
      child.active = Boolean(interaction);

      const label = child.getComponentInChildren(Label);
      if (label && interaction) {
        label.string = interaction.label;
      }

      const button = child.getComponent(Button);
      if (button) {
        button.clickEvents.length = 0;
        if (interaction) {
          const eventHandler = new Component.EventHandler();
          eventHandler.target = this.node;
          eventHandler.component = 'ChapterOneGreybox';
          eventHandler.handler = 'runInteraction';
          eventHandler.customEventData = interaction.id;
          button.clickEvents.push(eventHandler);
        }
      }
    });
  }

  private ensureRuntimeUi() {
    if (!this.sceneTitle) {
      this.sceneTitle = this.createLabel('SceneTitle', new Vec3(0, 240, 0), 28, new Color(235, 238, 226, 255), 660);
    }
    if (!this.sceneCopy) {
      this.sceneCopy = this.createLabel('SceneCopy', new Vec3(0, 190, 0), 18, new Color(198, 205, 196, 255), 660, 64);
    }
    if (!this.feedback) {
      this.feedback = this.createLabel('Feedback', new Vec3(0, 120, 0), 20, new Color(255, 232, 162, 255), 660, 72);
    }
    if (!this.chapterStatus) {
      this.chapterStatus = this.createLabel('ChapterStatus', new Vec3(0, -230, 0), 14, new Color(160, 174, 172, 255), 660, 140);
    }
    if (!this.interactionRoot) {
      this.interactionRoot = new Node('InteractionButtons');
      this.node.addChild(this.interactionRoot);
      this.interactionRoot.setPosition(new Vec3(-320, 50, 0));

      for (let index = 0; index < 10; index += 1) {
        const buttonNode = new Node(`InteractionButton${index + 1}`);
        const row = Math.floor(index / 2);
        const column = index % 2;
        buttonNode.setPosition(new Vec3(column * 340, -row * 44, 0));
        this.interactionRoot.addChild(buttonNode);

        const transform = buttonNode.addComponent(UITransform);
        transform.setContentSize(300, 36);

        buttonNode.addComponent(Button);
        const label = buttonNode.addComponent(Label);
        label.string = '';
        label.fontSize = 16;
        label.lineHeight = 22;
        label.color = new Color(228, 232, 220, 255);
      }
    }
  }

  private createLabel(name: string, position: Vec3, fontSize: number, color: Color, width = 720, height = 48): Label {
    const node = new Node(name);
    this.node.addChild(node);
    node.setPosition(position);

    const transform = node.addComponent(UITransform);
    transform.setContentSize(width, height);

    const label = node.addComponent(Label);
    label.string = '';
    label.fontSize = fontSize;
    label.lineHeight = fontSize + 6;
    label.color = color;
    label.horizontalAlign = Label.HorizontalAlign.LEFT;
    label.verticalAlign = Label.VerticalAlign.TOP;
    return label;
  }
}
