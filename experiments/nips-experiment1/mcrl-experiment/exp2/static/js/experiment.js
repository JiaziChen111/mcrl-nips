// Generated by CoffeeScript 1.12.3

/*
experiment.coffee
Fred Callaway

Demonstrates the jspsych-mdp plugin
 */
var DEBUG, PARAMS, blocks, condition, psiturk,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

DEBUG = false;

console.log(condition);

if (DEBUG) {
  console.log("X X X X X X X X X X X X X X X X X\n X X X X X DEBUG  MODE X X X X X\nX X X X X X X X X X X X X X X X X");
  condition = 1;
} else {
  console.log("# =============================== #\n# ========= NORMAL MODE ========= #\n# =============================== #");
}

psiturk = new PsiTurk(uniqueId, adServerLoc, mode);

PARAMS = void 0;

blocks = void 0;

(function() {
  var BONUS, Block, MDPBlock, QuizLoop, TextBlock, calculateBonus, debug_slide, delay, expData, experiment_timeline, finish, instruct_loop, instructions, main, myopic, nonmyopic, pre_retention, prompt_resubmit, quiz, reprompt, retention, save_data, text, trials, welcome;
  expData = loadJson('static/json/condition_1.json');
  console.log(expData);
  trials = expData.trials;
  PARAMS = expData.params.conditions[condition];
  psiturk.recordUnstructuredData('PARAMS', PARAMS);
  text = {
    debug: function() {
      if (DEBUG) {
        return "`DEBUG`";
      } else {
        return '';
      }
    },
    feedback: function() {
      if (PARAMS.feedback) {
        return [markdown("# Instructions\n\n<b>You will receive feedback about your planning. This feedback will\nhelp you learn how to make better decisions.</b> After each flight, if\nyou did not plan optimally, a feedback message will apear. This message\nwill tell you two things:\n\n1. Whether you observed too few relevant values or if you observed\n   irrelevant values (values of locations that you cant fly to).\n2. Whether you flew along the best route given your current location and\n   the information you had about the values of other locations.\n\nIn the example below, not enough relevant values were observed, and as a\nresult there is a 15 second timeout penalty. <b>The duration of the\ntimeout penalty is proportional to how poorly you planned your\nroute:</b> the more money you could have earned from observing more\nvalues and/or choosing a better route, the longer the delay. The second\nfeedback in the example below indicates the plane was flown along the\nbest route, given the limited information available. <b>If you perform\noptimally, no feedback will be shown and you can proceed immediately.</b>\nYou will only see feedback for the first 8 rounds.\n\n<div align=\"center\"><img src=\"static/js/images/instruction_images/Slide4.png\" width=600></div>")];
      } else {
        return [];
      }
    },
    constantDelay: function() {
      if (PARAMS.feedback) {
        return "";
      } else {
        return "Note: there will be short delays after taking some flights.";
      }
    }
  };
  Block = (function() {
    function Block(config) {
      _.extend(this, config);
      this.block = this;
      if (this.init != null) {
        this.init();
      }
    }

    return Block;

  })();
  TextBlock = (function(superClass) {
    extend(TextBlock, superClass);

    function TextBlock() {
      return TextBlock.__super__.constructor.apply(this, arguments);
    }

    TextBlock.prototype.type = 'text';

    TextBlock.prototype.cont_key = ['space'];

    return TextBlock;

  })(Block);
  QuizLoop = (function(superClass) {
    extend(QuizLoop, superClass);

    function QuizLoop() {
      return QuizLoop.__super__.constructor.apply(this, arguments);
    }

    QuizLoop.prototype.loop_function = function(data) {
      var c, i, len, ref;
      console.log('data', data);
      ref = data[data.length].correct;
      for (i = 0, len = ref.length; i < len; i++) {
        c = ref[i];
        if (!c) {
          return true;
        }
      }
      return false;
    };

    return QuizLoop;

  })(Block);
  MDPBlock = (function(superClass) {
    extend(MDPBlock, superClass);

    function MDPBlock() {
      return MDPBlock.__super__.constructor.apply(this, arguments);
    }

    MDPBlock.prototype.type = 'graph';

    MDPBlock.prototype.init = function() {
      return this.trialCount = 0;
    };

    return MDPBlock;

  })(Block);
  debug_slide = new Block({
    type: 'html',
    url: 'test.html'
  });
  welcome = new TextBlock({
    text: markdown("# Welcome\n\nThanks for accepting our HIT and taking part in our experiment.\nBefore you continue, we want to remind you that the HIT is expected\nto take 20 or 30 minutes depending on whether you are randomly chosen\nto take a 10 minute break after the 8th round.\n\nPress **space** to continue.")
  });
  instructions = new Block({
    type: "instructions",
    pages: [markdown("# Instructions " + (text.debug()) + "\n\nIn this game, you are in charge of flying an aircraft. As shown below,\nyou will begin in the central location. The arrows show which actions\nare available in each location. Note that once you have made a move you\ncannot go back; you can only move forward along the arrows. There are\neight possible final destinations labelled 1-8 in the image below. On\nyour way there, you will visit two intermediate locations. <b>Every\nlocation you visit will add or subtract money to your account</b>, and\nyour task is to earn as much money as possible. <b>To find out how much\nmoney you earn or lose in a location, you have to click on it.</b> You\ncan uncover the value of as many or as few locations as you wish.\n\n<div align=\"center\"><img src=\"static/js/images/instruction_images/Slide1.png\" width=600></div>\n\nTo navigate the airplane, use the arrows (the example above is non-interactive).\nYou can uncover the value of a location at any time. Click \"Next\" to proceed."), markdown("# Instructions\n\nYou will play the game for 12 rounds. The value of every location will\nchange from each round to the next. At the begining of each round, the\nvalue of every location will be hidden, and you will only discover the\nvalue of the locations you click on. The example below shows the value\nof every location, just to give you an example of values you could see\nif you clicked on every location. <b>Every time you click a circle to\nobserve its value, you pay a fee of 10 cents.</b> In the example below,\nthe current profit is $-1.60 because 16 locations have been inspected\nand none of their rewards has been collected yet. Each time you move to\na location, your profit will be adjusted. If you move to a location with\na hidden value, your profit will still be adjusted according to the\nvalue of that location. " + (text.constantDelay()) + "\n\n<div align=\"center\"><img src=\"static/js/images/instruction_images/Slide2.png\" width=600></div>")].concat((text.feedback()).concat([markdown("# Instructions\n\nThere are three more important things to understand:\n1. You must spend at least 45 seconds on each round.</b> As shown below,\n   there will be a countdown timer. You won’t be able to proceed to the\n   next round before the countdown has finished, but you can take as\n   much time as you like afterwards.\n2. You will earn <u>REAL MONEY</u> for your flights.</b> Specifically,\n   one of the 12 rounds will be chosen at random and you will receive 5%\n   of your earnings in that round as a bonus payment.\n\n<div align=\"center\"><img src=\"static/js/images/instruction_images/Slide3.png\" width=600></div>\n\n You may proceed to take an entry quiz, or go back to review the instructions.")])),
    show_clickable_nav: true
  });
  if (condition === 0) {
    quiz = new Block({
      preamble: function() {
        return markdown("# Quiz");
      },
      type: 'survey-multi-choice',
      questions: ["How many flights are there per round?", "True or false: The hidden values will change each time I start a new round.", "How much does it cost to observe each hidden value?", "How many hidden values am I allowed to observe in each round?", "Which statement is TRUE?"],
      options: [['1', '2', '3', '4'], ['True', 'False'], ['$0.00', '$0.10', '$0.25', '$0.50'], ['At most 1', 'At most 5', 'At most 10', 'At most 15', 'As many or as few as I wish'], ['My earnings for each round are equal to the value of one of the locations I visit (minus the cost of making observations), and I will actually be paid the earnings from one of the 12 rounds.', 'My earnings for each round are equal to the value of one of the locations I visit (minus the cost of making observations), but these earnings aren\'t real money.', 'My earnings for each round are equal to the <i>sum</i> of the values of all locations I visit (minus the cost of making observations), and I will be paid the earnings from one of the 12 rounds.', 'My earnings for each round are equal to the <i>sum</i> of the values of all locations I visit (minus the cost of making observations), but these earnings aren\'t real money.']],
      required: [true, true, true, true, true],
      correct: ['3', 'True', '$0.10', 'As many or as few as I wish', 'My earnings for each round are equal to the <i>sum</i> of the values of all locations I visit (minus the cost of making observations), and I will be paid the earnings from one of the 12 rounds.'],
      on_mistake: function(data) {
        return alert("You got at least one question wrong. We'll send you back to the\ninstructions and then you can try again.");
      }
    });
  } else if (condition === 1) {
    quiz = new Block({
      preamble: function() {
        return markdown("# Quiz");
      },
      type: 'survey-multi-choice',
      questions: ["How many flights are there per round?", "True or false: The hidden values will change each time I start a new round.", "How much does it cost to observe each hidden value?", "How many hidden values am I allowed to observe in each round?", "Which statement is TRUE?", "What does the feedback teach me?"],
      options: [['1', '2', '3', '4'], ['True', 'False'], ['$0.00', '$0.10', '$0.25', '$0.50'], ['At most 1', 'At most 5', 'At most 10', 'At most 15', 'As many or as few as I wish'], ['My earnings for each round are equal to the value of one of the locations I visit (minus the cost of making observations), and I will actually be paid the earnings from one of the 12 rounds.', 'My earnings for each round are equal to the value of one of the locations I visit (minus the cost of making observations), but these earnings aren\'t real money.', 'My earnings for each round are equal to the <i>sum</i> of the values of all locations I visit (minus the cost of making observations), and I will be paid the earnings from one of the 12 rounds.', 'My earnings for each round are equal to the <i>sum</i> of the values of all locations I visit (minus the cost of making observations), but these earnings aren\'t real money.'], ['Whether I observed the rewards of relevant locations.', 'Whether I chose the move that was best according to the information I had.', 'The duration of the delay tells me how much more money I could have earned by planning and deciding better.', 'All of the above.']],
      required: [true, true, true, true, true, true],
      correct: ['3', 'True', '$0.10', 'As many or as few as I wish', 'My earnings for each round are equal to the <i>sum</i> of the values of all locations I visit (minus the cost of making observations), and I will be paid the earnings from one of the 12 rounds.', 'All of the above.', 'True'],
      on_mistake: function(data) {
        return alert("You got at least one question wrong. We'll send you back to the\ninstructions and then you can try again.");
      }
    });
  } else if (condition === 2) {
    quiz = new Block({
      preamble: function() {
        return markdown("# Quiz");
      },
      type: 'survey-multi-choice',
      questions: ["How many flights are there per round?", "True or false: The hidden values will change each time I start a new round.", "How much does it cost to observe each hidden value?", "How many hidden values am I allowed to observe in each round?", "Which statement is TRUE?", "True of false: The duration of the delay tells me how much more money I could have earned by planning and deciding better."],
      options: [['1', '2', '3', '4'], ['True', 'False'], ['$0.00', '$0.10', '$0.25', '$0.50'], ['At most 1', 'At most 5', 'At most 10', 'At most 15', 'As many or as few as I wish'], ['My earnings for each round are equal to the value of one of the locations I visit (minus the cost of making observations), and I will actually be paid the earnings from one of the 12 rounds.', 'My earnings for each round are equal to the value of one of the locations I visit (minus the cost of making observations), but these earnings aren\'t real money.', 'My earnings for each round are equal to the <i>sum</i> of the values of all locations I visit (minus the cost of making observations), and I will be paid the earnings from one of the 12 rounds.', 'My earnings for each round are equal to the <i>sum</i> of the values of all locations I visit (minus the cost of making observations), but these earnings aren\'t real money.'], ['True', 'False']],
      required: [true, true, true, true, true, true],
      correct: ['3', 'True', '$0.10', 'As many or as few as I wish', 'My earnings for each round are equal to the <i>sum</i> of the values of all locations I visit (minus the cost of making observations), and I will be paid the earnings from one of the 12 rounds.', 'True'],
      on_mistake: function(data) {
        return alert("You got at least one question wrong. We'll send you back to the\ninstructions and then you can try again.");
      }
    });
  } else if (condition === 3) {
    quiz = new Block({
      preamble: function() {
        return markdown("# Quiz");
      },
      type: 'survey-multi-choice',
      questions: ["How many flights are there per round?", "True or false: The hidden values will change each time I start a new round.", "How much does it cost to observe each hidden value?", "How many hidden values am I allowed to observe in each round?", "Which statement is TRUE?", "What does the feedback teach me?"],
      options: [['1', '2', '3', '4'], ['True', 'False'], ['$0.00', '$0.10', '$0.25', '$0.50'], ['At most 1', 'At most 5', 'At most 10', 'At most 15', 'As many or as few as I wish'], ['My earnings for each round are equal to the value of one of the locations I visit (minus the cost of making observations), and I will actually be paid the earnings from one of the 12 rounds.', 'My earnings for each round are equal to the value of one of the locations I visit (minus the cost of making observations), but these earnings aren\'t real money.', 'My earnings for each round are equal to the <i>sum</i> of the values of all locations I visit (minus the cost of making observations), and I will be paid the earnings from one of the 12 rounds.', 'My earnings for each round are equal to the <i>sum</i> of the values of all locations I visit (minus the cost of making observations), but these earnings aren\'t real money.'], ['Whether I observed the rewards of relevant locations.', 'Whether I chose the move that was best according to the information I had.', 'All of the above.']],
      required: [true, true, true, true, true, true],
      correct: ['3', 'True', '$0.10', 'As many or as few as I wish', 'My earnings for each round are equal to the <i>sum</i> of the values of all locations I visit (minus the cost of making observations), and I will be paid the earnings from one of the 12 rounds.', 'All of the above.'],
      on_mistake: function(data) {
        return alert("You got at least one question wrong. We'll send you back to the\ninstructions and then you can try again.");
      }
    });
  }
  instruct_loop = new Block({
    timeline: [instructions, quiz],
    loop_function: function(data) {
      var c, i, len, ref;
      ref = data[1].correct;
      for (i = 0, len = ref.length; i < len; i++) {
        c = ref[i];
        if (!c) {
          return true;
        }
      }
      psiturk.finishInstructions();
      psiturk.saveData();
      return false;
    }
  });
  myopic = _.shuffle(trials.slice(-3));
  nonmyopic = _.shuffle(trials.slice(0, -3));
  main = new MDPBlock({
    timeline: _.shuffle(nonmyopic.slice(0, 6).concat(myopic.slice(0, 2)))
  });
  delay = PARAMS.break_duration ? new Block({
    type: 'delay',
    duration: PARAMS.break_duration
  }) : new TextBlock({
    text: markdown("# Break\n\nYou were not randomly chosen to take a break.\n\nPress **space** to continue immediately.")
  });
  pre_retention = new Block({
    timeline: [
      new TextBlock({
        text: markdown("# No more feedback\n\nFor the final 4 trials, you will not get any feedback or delays\nbased on your planning or decisions.\n\nPress **space** to continue.")
      })
    ],
    conditional_function: function() {
      return PARAMS.feedback;
    }
  });
  retention = new MDPBlock({
    feedback: false,
    timeline: _.shuffle(nonmyopic.slice(6).concat(myopic.slice(2)))
  });
  finish = new Block({
    type: 'button-response',
    stimulus: function() {
      return markdown("# This completes the HIT\n\nOne or your trials has been randomly selected and we will pay you 5% of\nyour profit on that trial as a bonus. You will be awarded a bonus of\n$" + (calculateBonus().toFixed(2)));
    },
    is_html: true,
    choices: ['Submit Hit'],
    button_html: '<button class="btn btn-primary btn-lg">%choice%</button>'
  });
  if (DEBUG) {
    experiment_timeline = [main, delay, pre_retention, retention, finish];
  } else {
    experiment_timeline = [welcome, instruct_loop, main, delay, pre_retention, retention, finish];
  }
  BONUS = void 0;
  calculateBonus = function() {
    var data;
    if (DEBUG) {
      return 0;
    }
    if (BONUS != null) {
      return BONUS;
    }
    data = jsPsych.data.getTrialsOfType('graph');
    BONUS = 0.05 * Math.max(0, (_.sample(data)).score);
    psiturk.recordUnstructuredData('final_bonus', BONUS);
    return BONUS;
  };
  reprompt = null;
  save_data = function() {
    return psiturk.saveData({
      success: function() {
        console.log('Data saved to psiturk server.');
        if (reprompt != null) {
          window.clearInterval(reprompt);
        }
        return psiturk.computeBonus('compute_bonus', psiturk.completeHIT);
      },
      error: function() {
        return prompt_resubmit;
      }
    });
  };
  prompt_resubmit = function() {
    $('#jspsych-target').html("<h1>Oops!</h1>\n<p>\nSomething went wrong submitting your HIT.\nThis might happen if you lose your internet connection.\nPress the button to resubmit.\n</p>\n<button id=\"resubmit\">Resubmit</button>");
    return $('#resubmit').click(function() {
      $('#jspsych-target').html('Trying to resubmit...');
      reprompt = window.setTimeout(prompt_resubmit, 10000);
      return save_data();
    });
  };
  return jsPsych.init({
    display_element: $('#jspsych-target'),
    timeline: experiment_timeline,
    on_finish: function() {
      if (DEBUG) {
        return jsPsych.data.displayData();
      } else {
        return save_data();
      }
    },
    on_data_update: function(data) {
      console.log('data', data);
      return psiturk.recordTrialData(data);
    }
  });
})();
