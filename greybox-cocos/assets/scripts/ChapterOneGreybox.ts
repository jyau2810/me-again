import { _decorator, Button, Component, Label, Node } from 'cc';
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
}
