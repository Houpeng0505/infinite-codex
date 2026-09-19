# Infinite Codex

> **Turn ChatGPT into Infinite Codex.**
>
> **Chat is the agent. GitHub is the memory. GitHub Actions is the computer.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Infinite Codex Runner](https://github.com/Houpeng0505/infinite-codex/actions/workflows/infinite-codex.yml/badge.svg?branch=infinite-codex%2Fdemo)](https://github.com/Houpeng0505/infinite-codex/actions/workflows/infinite-codex.yml)
[![Agent Skill](https://img.shields.io/badge/Agent%20Skill-SKILL.md-black)](.agents/skills/infinite-codex/SKILL.md)

**Verified end to end:** [live GitHub Actions demo](https://github.com/Houpeng0505/infinite-codex/actions/runs/35410394665) â€” the committed mission ran on a fresh GitHub-hosted VM, the self-test passed, and the execution artifact was uploaded.

Infinite Codex is a tiny open-source workflow that lets a capable ChatGPT session do repository work in a Codex-like loop **without running a second coding agent inside GitHub Actions**.

Chat reasons. GitHub persists the code. GitHub Actions executes the real build/test commands. The results come back to Chat, which decides the next edit.

## Why this exists

A coding agent needs two things:

1. **Intelligence** â€” understand the task, inspect code, plan changes, debug failures.
2. **A computer** â€” install dependencies, run tests, build, benchmark, and execute scripts.

ChatGPT already provides the first part. GitHub Actions can provide the second.

```text
                       Infinite Codex

                    ChatGPT / Chat
                         AGENT
                           â”‚
               reason Â· plan Â· debug
                           â”‚
                           â–¼
                    GitHub Repository
                   PERSISTENT MEMORY
                 read Â· edit Â· commit
                           â”‚
                           â–¼
                    GitHub Actions
                       COMPUTER
              install Â· run Â· build Â· test
                           â”‚
                           â–¼
              logs Â· artifacts Â· status
                           â”‚
                           â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–º Chat
                                              â”‚
                                           diagnose
                                              â”‚
                                              â””â”€â”€ next edit
```

No agent-in-agent stack. No model call from the runner. No autonomous LLM hidden inside CI.

## Requirements

Infinite Codex needs a Chat/agent surface that can:

- read the target GitHub repository;
- create or update branches and commit file changes;
- inspect GitHub Actions run status and logs (and optionally artifacts).

GitHub Actions must also be enabled for the repository. Different ChatGPT plans, surfaces, and GitHub integrations may expose different repository operations; if the current Chat can only read GitHub, the fully automated loop is not available in that surface.

## The loop

```text
Understand task
    â†“
Inspect repository
    â†“
Edit code + verification mission
    â†“
Commit to infinite-codex/<task>
    â†“
GitHub Actions starts a fresh VM
    â†“
Run the mission
    â†“
Read status / logs / artifact
    â†“
Diagnose and edit again
    â†“
Repeat until green
```

The runner is intentionally disposable. Persistent state belongs in Git: source, configuration, commits, and anything else that should survive the VM.

## 3-minute setup

### 1. Copy Infinite Codex[È[İ\ˆ™\ÜÚ]ÜB‚ÛÜH\ÙHš[\ËÙ\™XİÜšY\Î‚‚˜^QÑS•Ë›Y‹˜YÙ[ËÜÚÚ[ËÚ[™š[š]KXÛÙ^Â‹™Ú]X‹İÛÜšÙ›İÜËÚ[™š[š]KXÛÙ^[[‹š[™š[š]KXÛÙ^Ü[›™\‹œÚ‹š[™š[š]KXÛÙ^ÛZ\ÜÚ[Û‹œÚ˜‚“Ü‹œ›ÛHHÛÛ™HÙˆ\È™\ÜÚ]ÜN‚‚˜˜\Ú‹‹Ú[œİ[œÚÜ]İËŞ[İ\‹Ü™\ÜÚ]ÜB˜‚ˆÈÈÈ‹ˆ]Ú]ÛÜšÈÛˆHYXØ]Yœ˜[˜Ú‚•\ÙHHœ˜[˜ÚİXÚ\Î‚‚˜^š[™š[š]KXÛÙ^ØY[ÙÚ[‹X\B˜‚”\Ú\ÈÈ[™š[š]KXÛÙ^ÊŠ˜]]ÛX]XØ[HšYÙÙ\ˆH[›™\‹ˆÛÜšÙ›İ×Ù\Ü]Ú\È[ÛÈ[˜X›Y\ÈHX[X[˜[˜XÚË‚‚ˆÈÈÈËˆÚ]™HÚ]H\ÚÂ‚H\ÙY[š\œİ[œİXİ[Ûˆ\Î‚‚˜^•\ÙHH[™š[š]HÛÙ^ÚÚ[[ˆ\È™\ÜÚ]ÜK‚’[\[Y[H™\]Y\İYÚ[™ÙHÛˆ[ˆ[™š[š]KXÛÙ^Êˆœ˜[˜Ú‚’ÙY\š[™š[š]KXÛÙ^ÛZ\ÜÚ[Û‹œÚ›Øİ\ÙYÛˆHÛÛ[X[™È]›İ™HHÚ[™ÙHÛÜšÜË‚Y\ˆXXÚÛÛ[Z][œÜXİHÚ]XˆXİ[ÛœÈ™\İ[[™]\˜]H[[HZ\ÜÚ[Ûˆ\ÜÙ\Ë‚‘È›İ[YØ]HHÛÙ[™ÈÛÜšÈÈ[›İ\ˆRHYÙ[‚˜‚•]\ÈH›ÙXİ‚‚ˆÈÈÚ]H[›™\ˆXİX[HÙ\Â‚•HÛÜšÙ›İÈÚXÚÜÈİ]HÛÛ[Z]Y™]š\Ú[Ûˆ[™^Xİ]\Î‚‚˜˜\Ú˜˜\Úš[™š[š]KXÛÙ^ÛZ\ÜÚ[Û‹œÚ˜‚˜[›™\‹œÚ™XÛÜ™Î‚‚‹HHZ\ÜÚ[Ûˆ^]ÛÙNÂ‹H™\ÜÚ]ÜHÈœ˜[˜ÚÈÛÛ[Z]Y]Y]NÂ‹HHÛÛXš[™Y^Xİ][ÛˆÙÎÂ‹HHX\šÙİÛˆ[ˆİ[[X\NÂ‹HHXXÚ[™K\™XYX›H™\İ[šœÛÛ˜‚‚•Hš[™š[š]KXÛÙ^Ûİ]Ø\™XİÜH\È\ØYY\ÈHÚ]XˆXİ[ÛœÈ\Y˜XİÛˆ]™\H[‹[˜ÛY[™È˜Z[\™\Ë‚‚•HXİ[Ûˆ™XÙZ]™\ÈÛ›HÛÛ[Îˆ™XY\›Z\ÜÚ[ÛˆHY˜][ˆ]Ù\È
Š››İ
ŠˆÛÛ[Z]Ú[™Ù\ËÜ[ˆœËÜˆØ[[ˆRH[Ù[ˆÚ]İÛœÈÜÙHXÚ\Ú[ÛœË‚‚ˆÈÈ^[\HZ\ÜÚ[ÛœÂ‚ˆÈÈÈ]ÛˆÈ]\İ‚˜˜\ÚˆÈKİ\Ü‹Øš[‹Ù[ˆ˜\ÚœÙ]Y][È\Y˜Z[œ]Ûˆ[H\[œİ[YH	Ë–Ù]—IÂœ]Ûˆ[H]\İ\B˜‚ˆÈÈÈ›ÙB‚˜˜\ÚˆÈKİ\Ü‹Øš[‹Ù[ˆ˜\ÚœÙ]Y][È\Y˜Z[›œHÚB›œH\İ›œH[ˆZ[KZY‹\™\Ù[˜‚ˆÈÈÈ[H™\ÜÚ]ÜB‚˜˜\ÚˆÈKİ\Ü‹Øš[‹Ù[ˆ˜\ÚœÙ]Y][È\Y˜Z[‹‹ÜØÜš\ËÚ[œİ[Y\ËœÚ‹‹ÜØÜš\Ëİ\İœÚ‹‹ÜØÜš\ËØZ[œÚ˜‚“[Ü™H^[\\È\™H[ˆØ^[\\ËØJ^[\\ËÊK‚‚ˆÈÈÚH›İ]ÛÙ^ÈÛ]YHÛÙHÈ[›İ\ˆYÙ[[œÚYHXİ[ÛœÏÂ‚™XØ]\ÙH]\ÈHY™™\™[\˜Ú]Xİ\™K‚‚˜^YÙ[Z[‹PXİ[ÛœÈ\›ØXÚ[™š[š]HÛÙ^¸¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ 8¥ Ú]Ú]ˆ8¡¤È8¡¤ÂœÙXÛÛ™ÛÙ[™ÈYÙ[Ú]X‚ˆ8¡¤È8¡¤Âœ[›™\ˆXİ[ÛœÈ[›™\‚˜‚’[™š[š]HÛÙ^™X]ÈÚ]XˆXİ[ÛœÈ\ÈH
Š˜ÛÛ\]\ŠŠ‹›İ[ˆYÙ[ˆH™X\ÛÛš[™ÈÛÜİ^\È[ˆHÚ]ÛÛ™\œØ][Ûˆ][™XYH[™\œİ[™ÈH\Ù\‰ÜÈ[[‚‚ˆÈÈÚ]\È\ÈÛÛÙ›Ü‚‚‹H[\[Y[][Ûˆ]™YYÈ™X[\İÈ˜]\ˆ[ˆİY\ÜÙYÛÜœ™Xİ™\ÜÎÂ‹H\[™[˜ŞH[œİ[][Ûˆ]Ù\È›İš]HÚ]Ø[™›ŞÂ‹H[^[Û›H™\›ÙXİ[ÛÂ‹HZ[Ë[\œË›Ü›X]\œË\HÚXÚÜË™[˜ÚX\šÜË[™[YÜ˜][Ûˆ\İÎÂ‹H™\Ù\š[™È[ˆ]Y]X›HÚ]\İÜHÚ[HÚ]]\˜]\ÎÂ‹H\Ú[™ÈH\ÜÜØX›HÛX[ˆ[š\›Û›Y[ÈØ]Ú8 'ÛÜšÜÈÛˆ^HXXÚ[™x 'H\Üİ[\[ÛœË‚‚ˆÈÈÚ]\È\È›İ‚‹H[ˆÜ[RHÛÙ^][İH\\ÜÎÂ‹HHØ^HÈØZ[ˆ[›[Z]Y[Ù[\ØYÙNÂ‹HH™\XÙ[Y[›ÜˆÚ]XˆXİ[ÛœÈÙXİ\š]HÛÛ›ÛÎÂ‹HH\œÚ\İ[“NÂ‹H[ˆYÙ[[›š[™È[˜][™Y›Ü™]™\Â‹HH™X\ÛÛˆÈ]ÙXÜ™]È[È›Û\ËÛÛ[Z]ËÜˆÙÜË‚‚ˆÈÈÙXİ\š]H[Ù[‚•HÛÛ[Z]YZ\ÜÚ[Ûˆ\È^Xİ]X›HÛÙKˆ™X]Ú[™Ù\ÈÈš[™š[š]KXÛÙ^ÛZ\ÜÚ[Û‹œÚ^XİHZÙHÚ[™Ù\ÈÈ[HÒHÛÜšÙ›İË‚‚•HY˜][ÛÜšÙ›İÈ\™Y›Ü™N‚‚‹H[œÈÛ›HÛˆÛÜšÙ›İ×Ù\Ü]ÚÜˆ\Ú\ÈÈ[™š[š]KXÛÙ^ÊŠ˜Â‹H\Ù\ÈHÚ]X‹ZÜİY[›™\Â‹HÜ˜[ÈÒUP—ÕÒÑS˜Û›HÛÛ[Îˆ™XYÂ‹HÙ\È›İ\ÙH[Ü™\]Y\İİ\™Ù]Â‹HÙ\È›İ[\œÛ]H\ÜİYH]\Ëˆ›ÙY\ËÜˆİ\ˆ[\İY^[ÈÚ[ÛÛ[X[™ÎÂ‹H\ØYÈ^Xİ][Ûˆ\Y˜XİÈ]™[ˆÚ[ˆHZ\ÜÚ[Ûˆ˜Z[Ë‚‚”™XYØÑPÕT’UK›YJÑPÕT’UK›Y
H[™HÚÚ[ÙXİ\š]H™Y™\™[˜ÙH™Y›Ü™HY[™È™\ÜÚ]ÜHÙXÜ™]ÈÜˆ^[™[™È\›Z\ÜÚ[ÛœË‚‚ˆÈÈYÙ[ÚÚ[‚–Ø˜YÙ[ËÜÚÚ[ËÚ[™š[š]KXÛÙ^ÔÒÒS›YJ˜YÙ[ËÜÚÚ[ËÚ[™š[š]KXÛÙ^ÔÒÒS›Y
H›ÛİÜÈHÜX›HYÙ[ÚÚ[ÈÛÛ™[[ÛˆPSSY]Y]H\ÈÛÛ˜Ú\ÙHÜ\˜][Û˜[[œİXİ[ÛœËˆQÑS•Ë›Y\ÈHYÚÙZYÚ™\ÜÚ]ÜH[HÚ[[™]Z[YX]\šX[İ^\È™\ÚYHHÚÚ[[ˆ]È™Y™\™[˜Ù\ËØ\™XİÜK‚‚•HÚÚ[\ÈÛ™H›Û‹[™YÛİXX›H[N‚‚ˆ
ŠÚ]İÛœÈ™X\ÛÛš[™ËˆXİ[ÛœÈİÛœÈ^Xİ][Û‹ˆÈ›İÚ[[H[œÙ\[›İ\ˆÛÙ[™ÈYÙ[™]ÙY[ˆ[KŠŠ‚‚ˆÈÈ\ÚYÛˆš[˜Ú\\Â‚ŒKˆ
Š“Û™Hœ˜Z[‹ŠŠˆHXİ]™HÚ]Ù\ÜÚ[Ûˆ™[XZ[œÈHÛÛH™X\ÛÛš[™ÈYÙ[‚Œ‹ˆ
Š‘Ú]\ÈY[[ÜKŠŠˆ[][™È[\Ü[[›İYÚÈİ\š]™HH[ˆÚİ[™HÛÛ[Z]YÜˆİÜ™Y\È[ˆ\Y˜Xİ‚ŒËˆ
ŠXİ[ÛœÈ\È\ÜÜØX›HÛÛ\]KŠŠˆ™]™\ˆ\[™Ûˆ[›™\‹[ØØ[İ]Hİ\š]š[™ÈH›Ø‹‚ˆ
Š•™\šYšXØ][Ûˆİ™\ˆÛÛ™šY[˜ÙKŠŠˆHÛÛ[Z]\È›İ›ÛÙ‹ˆH™[]˜[İXØÙ\ÜÙ[Z\ÜÚ[Ûˆ\È]šY[˜ÙK‚Kˆ
Š”ÛX[Z\ÜÚ[ÛœËŠŠˆXXÚ[ˆÚİ[[œİÙ\ˆHÛÛ˜Ü™]H[™Ú[™Y\š[™È]Y\İ[Û‹‚‹ˆ
Š“X\İš]š[YÙKŠŠˆH[›™\ˆÚİ[™YY™\H]H]]Üš]H™XØ]\ÙH]Ù\È›İİÛˆ™\ÜÚ]ÜHXÚ\Ú[ÛœË‚Ëˆ
Š”™XYX›H\İÜKŠŠˆÛÛ[Z]ÈÚİ[\ØÜšX™HYX[š[™Ù[ÚXÚÜÚ[Ë›İYHHÛÜ‚‚ˆÈÈ™\ÜÚ]ÜH^[İ]‚˜^‹‚¸¥'8¥ 8¥ ‘PQQK›Y¸¥'8¥ 8¥ QÑS•Ë›Y¸¥'8¥ 8¥ \Ë¸¥'8¥ 8¥ PÑS”ÑB¸¥'8¥ 8¥ TĞÓRSQT‹›Y¸¥'8¥ 8¥ ÑPÕT’UK›Y¸¥'8¥ 8¥ ÓÓ•’P•US‘Ë›Y¸¥'8¥ 8¥ USÒ›Y¸¥'8¥ 8¥ [œİ[œÚ¸¥'8¥ 8¥ ˜YÙ[ËÂ¸¥ ˆ8¥%8¥ 8¥ ÚÚ[ËÂ¸¥ ˆ8¥%8¥ 8¥ [™š[š]KXÛÙ^Â¸¥ ˆ8¥'8¥ 8¥ ÒÒS›Y¸¥ ˆ8¥%8¥ 8¥ ™Y™\™[˜Ù\ËÂ¸¥ ˆ8¥'8¥ 8¥ PÕSÓ”×ÓÓÔ›Y¸¥ ˆ8¥'8¥ 8¥ TÒUPÕT‘K›Y¸¥ ˆ8¥%8¥ 8¥ ÑPÕT’UK›Y¸¥'8¥ 8¥ ™Ú]X‹Â¸¥ ˆ8¥%8¥ 8¥ ÛÜšÙ›İÜËÂ¸¥ ˆ8¥%8¥ 8¥ [™š[š]KXÛÙ^[[¸¥'8¥ 8¥ š[™š[š]KXÛÙ^Â¸¥ ˆ8¥'8¥ 8¥ Z\ÜÚ[Û‹œÚ¸¥ ˆ8¥%8¥ 8¥ [›™\‹œÚ¸¥'8¥ 8¥ ^[\\ËÂ¸¥ ˆ8¥'8¥ 8¥ Ù[™\šXË›Z\ÜÚ[Û‹œÚ¸¥ ˆ8¥'8¥ 8¥ ›ÙK›Z\ÜÚ[Û‹œÚ¸¥ ˆ8¥%8¥ 8¥ ]Û‹›Z\ÜÚ[Û‹œÚ¸¥%8¥ 8¥ ØÜš\ËÂˆ8¥%8¥ 8¥ Ù[‹]\İœÚ˜‚ˆÈÈTB‚ˆÈÈÈ\ÈH]™[ÜY[][İH]\˜[H[™š[š]OÂ‚“›ËˆÚ]Ô[œÈ[™Ú]XˆXİ[ÛœÈ›İ]™HZ\ˆİÛˆ[Z]È[™ÛXÚY\ËˆH˜[YH\ØÜšX™\ÈHÛÜšÙ›İÈYXNˆ[İ™H^Xİ][Ûˆ[ÈÚ]XˆXİ[ÛœÈÛÈHÚ]Ù\ÜÚ[ÛˆØ[ˆÙY\Ú[™È™\šYšYY™\ÜÚ]ÜHÛÜšÈÚ]İ]XZÚ[™ÈÛÙ^H^Xİ][Ûˆ^Y\‹‚‚ˆÈÈÈÙ\È\È™\]Z\™HÔMKˆÛÛÂ‚“›ËˆH\˜Ú]Xİ\™H\È[Ù[XYÛ›ÜİXËˆ[HİY™šXÚY[HØ\X›HÚ]ØYÙ[Üİ]Ø[ˆ™XY[™Üš]HH™\ÜÚ]ÜH[™[œÜXİXİ[ÛœÈ™\İ[ÈØ[ˆ\ÙHHÛÜ‚‚ˆÈÈÈÙ\ÈÚ]XˆXİ[ÛœÈ™[Y[X™\ˆ™]š[İ\È[œÏÂ‚“›ËˆÚ]X‹ZÜİY[›™\œÈ\™H\ÜÜØX›Kˆ\œÚ\İÛİ\˜ÙKÜİ]H[ˆÚ][™\œÚ\İ[ˆİ]]È\È\Y˜XİÈÚ[ˆ™YYY‚‚ˆÈÈÈÚHHYXØ]Yœ˜[˜Ú™Yš^Â‚’]Ú]™\ÈH^Xİ][Ûˆ›İ[™\HHš\ÚX›K]Y]X›HšYÙÙ\‹ˆÜ™[˜\H\Ú\È[Ù]Ú\™HÈ›İİ\H[™š[š]HÛÙ^[›™\‹‚‚ˆÈÈÈØ[ˆH\ÙHHÙ[‹ZÜİY[›™\Â‚•XÚšXØ[HY\Ë]]Ú[™Ù\ÈH™X][Ù[İXœİ[X[Kˆ\È[\]H[[[Û˜[HY˜][ÈÈÚ]X‹ZÜİYX[K[]\İ‚‚ˆÈÈ˜Y[X\šÈ	ˆY™š[X][Û‚‚’[™š[š]HÛÙ^\È[ˆ[™\[™[Ü[‹\Ûİ\˜ÙH›Ú™Xİ[™\È›İY™š[X]YÚ][™ÜœÙYKÜÛœÛÜ™YKÜˆ›ÙXÙYHÜ[RKˆÜ[RKÚ]ÔÛÙ^[™™[]Y˜[Y\È[™X\šÜÈ™[Û™ÈÈZ\ˆ™\ÜXİ]™HİÛ™\œËˆÙYHØTĞÓRSQT‹›YJTĞÓRSQT‹›Y
H›ÜˆH[›İXÙK‚‚•H˜[YH
Š’[™š[š]HÛÙ^
ŠˆÙ\È›İYX[ˆ\È›Ú™XİÜ˜[È[›[Z]YÜ[RHÛÙ^\ØYÙKÚ[™Ù\ÈÜ[RH][İ\ËÜˆ\\ÜÙ\È›ÙXİ™\İšXİ[ÛœË‚‚ˆÈÈXÙ[œÙB‚“RUˆÙYHØPÑS”ÑXJPÑS”ÑJK‚‚‹KKB‚ŠŠÚ]\ÈHYÙ[ˆÚ]Xˆ\ÈHY[[ÜKˆÚ]XˆXİ[ÛœÈ\ÈHÛÛ\]\‹ŠŠ‚