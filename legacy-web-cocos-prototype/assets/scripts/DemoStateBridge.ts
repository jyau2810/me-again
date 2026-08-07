import { _decorator, Component, Label } from 'cc';

const { ccclass, property } = _decorator;

export type SceneId =
  | 'reality-school-gate'
  | 'playground-loop'
  | 'chalk-corridor'
  | 'old-desk-island'
  | 'ending-reality-echo';

export type PerceptionStage = 'opening' | 'afterChapter' | 'endingEcho';

export interface PuzzleState {
  chalkRuleRead: boolean;
  deskMapRead: boolean;
  trueFourthLoopFound: boolean;
}

export interface SaveData {
  version: number;
  currentScene: SceneId;
  chapterProgress: 'opening' | 'innerWorld' | 'ending';
  loopCount: number;
  perceptionStage: PerceptionStage;
  puzzleState: PuzzleState;
  collectedItems: string[];
}

export interface SceneState {
  id: SceneId;
  title: string;
  copy: string;
  interactions: Interactable[];
}

export interface Interactable {
  id: string;
  label: string;
  type: 'perception' | 'puzzleHint' | 'collectible' | 'hint';
}

export interface PerceptionText {
  objectId: string;
  opening: string;
  afterChapter: string;
  endingEcho: string;
}

export interface Collectible {
  id: 'half-chalk' | 'sticker-star';
  label: string;
  collectedText: string;
}

const initialSaveData: SaveData = {
  version: 1,
  currentScene: 'reality-school-gate',
  chapterProgress: 'opening',
  loopCount: 0,
  perceptionStage: 'opening',
  puzzleState: {
    chalkRuleRead: false,
    deskMapRead: false,
    trueFourthLoopFound: false,
  },
  collectedItems: [],
};

@ccclass('DemoStateBridge')
export class DemoStateBridge extends Component {
  @property(Label)
  public sceneTitle: Label | null = null;

  @property(Label)
  public sceneCopy: Label | null = null;

  @property(Label)
  public feedback: Label | null = null;

  private saveData: SaveData = { ...initialSaveData };

  start() {
    this.render('树影贴在校门边，像一条没写完的线。');
  }

  public performLoop() {
    this.saveData.loopCount = Math.min(this.saveData.loopCount + 1, 4);
    if (this.saveData.loopCount >= 3) {
      this.saveData.currentScene = 'playground-loop';
      this.saveData.chapterProgress = 'innerWorld';
      this.saveData.perceptionStage = 'afterChapter';
      this.render('第三圈。粉笔箭头出现了，跑道线像一条会拐弯的路。');
      return;
    }
    this.render(`第 ${this.saveData.loopCount} 圈。学校还是学校，只是窗户亮了一点。`);
  }

  public moveToChalkCorridor() {
    this.moveToScene('chalk-corridor');
  }

  public moveToOldDeskIsland() {
    this.moveToScene('old-desk-island');
  }

  public readChalkRule() {
    this.saveData.puzzleState.chalkRuleRead = true;
    this.render('第四圈要慢慢跑，不然门会装作没看见。');
  }

  public readDeskMap() {
    this.saveData.puzzleState.deskMapRead = true;
    this.render('桌角画着小地图：三圈以后，从影子短的那边开始第四圈。');
  }

  public collectHalfChalk() {
    this.collect('half-chalk', '半截粉笔被放进铁皮盒。');
  }

  public collectStickerStar() {
    this.collect('sticker-star', '贴纸星星被放进铁皮盒。');
  }

  public performTrueFourthLoop() {
    if (!this.saveData.puzzleState.chalkRuleRead || !this.saveData.puzzleState.deskMapRead) {
      this.render('还缺一条小孩留下的规则。');
      return;
    }
    this.saveData.currentScene = 'ending-reality-echo';
    this.saveData.chapterProgress = 'ending';
    this.saveData.loopCount = 4;
    this.saveData.perceptionStage = 'endingEcho';
    this.saveData.puzzleState.trueFourthLoopFound = true;
    this.render('第四圈慢慢跑完。门没有打开，世界自己退回了现实。');
  }

  private moveToScene(sceneId: SceneId) {
    if (this.saveData.chapterProgress === 'opening') {
      this.render('学校还没有靠近那边。');
      return;
    }
    this.saveData.currentScene = sceneId;
    this.render(sceneCopy[sceneId]);
  }

  private collect(itemId: Collectible['id'], message: string) {
    if (!this.saveData.collectedItems.includes(itemId)) {
      this.saveData.collectedItems.push(itemId);
    }
    this.render(message);
  }

  private render(message: string) {
    if (this.sceneTitle) {
      this.sceneTitle.string = sceneTitles[this.saveData.currentScene];
    }
    if (this.sceneCopy) {
      this.sceneCopy.string = sceneCopy[this.saveData.currentScene];
    }
    if (this.feedback) {
      this.feedback.string = message;
    }
  }
}

const sceneTitles: Record<SceneId, string> = {
  'reality-school-gate': '学校门口',
  'playground-loop': '操场环线',
  'chalk-corridor': '粉笔走廊',
  'old-desk-island': '旧课桌岛',
  'ending-reality-echo': '结尾回声',
};

const sceneCopy: Record<SceneId, string> = {
  'reality-school-gate': '下班路过学校。树、花、校门和路灯都很普通，像被快速看了一眼。',
  'playground-loop': '第三圈以后，跑道线弯成奇怪的路。窗户里有一点暖光。',
  'chalk-corridor': '墙上的粉笔箭头像小孩写下的规则，短短的，但很认真。',
  'old-desk-island': '课桌排成小岛，抽屉和桌角藏着以前留下来的东西。',
  'ending-reality-echo': '回到现实以后，学校没有变大，也没有变小。只是你看它的方式变了一点。',
};
