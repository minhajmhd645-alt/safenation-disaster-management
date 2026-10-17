<?php
declare(strict_types=1);
final class Severity {
    /** Explainable academic baseline: not a trained predictive model. */
    public static function classify(string $type, string $text, int $people, string $damage): array {
        $score=0; $reasons=[];
        if ($people>=100) {$score+=6;$reasons[]='100 or more people reported affected';}
        elseif ($people>=25) {$score+=4;$reasons[]='25–99 people reported affected';}
        elseif ($people>=5) {$score+=2;$reasons[]='5–24 people reported affected';}
        $weights=['none'=>0,'minor'=>1,'moderate'=>3,'severe'=>6];
        $score += $weights[$damage] ?? 0;
        if ($damage!=='none') $reasons[]=$damage.' reported damage';
        if (in_array($type,['Fire','Landslide'],true)) {$score++;$reasons[]='fire or landslide adds to the priority score';}
        $text=strtolower($text);
        foreach (['trapped','injured','collapsed','missing','fatal','unconscious'] as $word) {
            // Negated signals do not add weight. Still requires human interpretation.
            if (preg_match('/\b'.$word.'\b/',$text) && !preg_match('/\b(no|not|without)\s+(?:\w+\s+){0,2}'.$word.'\b/',$text)) {
                $score+=3;$reasons[]='report mentions: '.$word;
            }
        }
        $level=$score>=10?'Critical':($score>=6?'High':($score>=3?'Medium':'Low'));
        return ['level'=>$level,'score'=>$score,'reason'=>implode('; ',$reasons) ?: 'The report contains few indicators of serious impact'];
    }
}
